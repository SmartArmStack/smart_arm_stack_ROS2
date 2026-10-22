#!/usr/bin/env bash
#
# SmartArmStack (SAS) apt bootstrap for ROS 2 jazzy.
set -Eeuo pipefail

SAS_APT_URL="${SAS_APT_URL:-https://smartarmstack.github.io/smart_arm_stack_ROS2}"
SAS_DBGSYM="${SAS_DBGSYM:-0}"

usage() {
  cat <<'EOF'
Usage: install.sh [-n|--dry-run] [-v|--verbose] [-h|--help]

Install the SmartArmStack ROS 2 packages from the SAS apt repository.
Safe to run as root or as a normal user (sudo is used only when needed).

Options:
  -n, --dry-run   Print the privileged steps instead of running them
  -v, --verbose   Explain what is being reused/skipped
  -h, --help      Show this help

Environment:
  SAS_APT_URL       Base URL of the SAS apt repo
  SAS_DBGSYM        1 = also install the -dbgsym debug-symbol packages
EOF
}

DRY_RUN=0
VERBOSE=0
for arg in "$@"; do
  case "$arg" in
  -n | --dry-run) DRY_RUN=1 ;;
  -v | --verbose) VERBOSE=1 ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "install.sh: unknown option: $arg (try --help)" >&2
    exit 2
    ;;
  esac
done

log() { echo "[install.sh] $*"; }
vlog() {
  if ((VERBOSE)); then echo "[install.sh] $*"; fi
}
die() {
  echo "[install.sh] ERROR: $*" >&2
  exit 1
}

# --- Privileges --------------------------------------------------------------
SUDO=()
SUDO_PREFIX=""
if [[ $(id -u) -ne 0 ]]; then
  command -v sudo >/dev/null 2>&1 ||
    die "installing needs administrator rights to write under /etc/apt. Run it as 'sudo bash install.sh'."
  SUDO=(sudo)
  SUDO_PREFIX="sudo "

  # Authenticate up front so the password is asked once, here. 'sudo -v' prompts on
  # the controlling terminal, which survives 'curl ... | bash', and fails at once
  # when there is no terminal.
  if ! ((DRY_RUN)) && ! sudo -n true 2>/dev/null && ! sudo -v; then
    die "could not get sudo credentials. Run 'sudo bash install.sh', or cache them with 'sudo -v' first."
  fi
fi

as_root() {
  if ((DRY_RUN)); then
    echo "[install.sh] (dry-run) ${SUDO_PREFIX}$*"
  else
    "${SUDO[@]}" "$@"
  fi
}

apt_run() {
  if ((DRY_RUN)); then
    echo "[install.sh] (dry-run) ${SUDO_PREFIX}apt-get $*"
  else
    "${SUDO[@]}" apt-get "$@"
  fi
}

if [[ ! -t 0 && -z "${DEBIAN_FRONTEND:-}" ]]; then
  export DEBIAN_FRONTEND=noninteractive
  vlog "no tty: DEBIAN_FRONTEND=noninteractive"
fi

# --- Prerequisites -----------------------------------------------------------
# Install only what is missing, so a re-run on a prepared machine stays a no-op.
missing_pkgs=()
for tool in curl gpg dpkg apt-cache; do
  case "$tool" in
  curl) pkg=curl ;;
  gpg) pkg=gnupg ;;
  dpkg) pkg=dpkg ;;
  apt-cache) pkg=apt ;;
  esac
  if ! command -v "$tool" >/dev/null 2>&1; then
    missing_pkgs+=("$pkg")
    if [[ "$tool" == curl ]]; then missing_pkgs+=(ca-certificates); fi
  fi
done
if ((${#missing_pkgs[@]} > 0)); then
  log "installing missing tool(s): ${missing_pkgs[*]}"
  apt_run update -q || die "apt-get update failed while installing the prerequisites: ${missing_pkgs[*]}"
  apt_run install -y --no-install-recommends "${missing_pkgs[@]}" ||
    die "could not install the prerequisites: ${missing_pkgs[*]}"
  if ((!DRY_RUN)); then
    for tool in curl gpg dpkg apt-cache; do
      command -v "$tool" >/dev/null 2>&1 ||
        die "$tool is still missing after installing ${missing_pkgs[*]}"
    done
  fi
fi

# --- Detect where we are -----------------------------------------------------
distro=jazzy

codename="$(sed -n 's/^VERSION_CODENAME=//p' /etc/os-release 2>/dev/null || true)"
[[ -n "$codename" ]] || codename="$(lsb_release -cs 2>/dev/null || true)"
[[ -n "$codename" ]] ||
  die "cannot detect the Ubuntu codename: neither /etc/os-release nor lsb_release works here."

arch="$(dpkg --print-architecture)"
log "user=$(id -un) root=$(if [[ $(id -u) -eq 0 ]]; then echo yes; else echo no; fi) | ros=$distro | ubuntu=$codename | arch=$arch"

# --- Apt sources -------------------------------------------------------------
sas_url="$SAS_APT_URL"
gazebo_url="https://packages.osrfoundation.org/gazebo/ubuntu-stable"
ros_url="http://packages.ros.org/ros2/ubuntu"
dq_url="http://ppa.launchpadcontent.net/dqrobotics-dev/development/ubuntu"
dq_fingerprint=C8871E1A46BFD53FF3E9D3D9156C628C782BD123
sas_keyring=/etc/apt/keyrings/smartarmstack.gpg
gazebo_keyring=/etc/apt/keyrings/gazebo-stable.gpg
ros_keyring=/etc/apt/keyrings/ros2.gpg
dq_keyring=/etc/apt/keyrings/dqrobotics-dev-development.gpg

sas_list=/etc/apt/sources.list.d/smartarmstack.list
gazebo_list=/etc/apt/sources.list.d/gazebo-stable.list
ros_list=/etc/apt/sources.list.d/ros2.list
dq_list=/etc/apt/sources.list.d/dqrobotics-dev-ubuntu-development.list

# apt refuses two entries for the same URI with different Signed-By values
# ("Conflicting values set for option Signed-By"), so every URI is configured
# only when no apt file references it already: the main file and
# sources.list.d, one-line or deb822 syntax, symlinks included.
sas_host="${sas_url#*://}"
gazebo_host="${gazebo_url#*://}"
ros_host="packages.ros.org/ros2/ubuntu"
dq_host="dqrobotics-dev/development"

uri_known() { # $1 = host/path substring of the URI
  grep -RqF "$1" /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null
}

# Removes a list file this script wrote when the same URI also appears in
# /etc/apt/sources.list, the one place this script will not touch.
drop_dup_list() { # $1 = our list file, $2 = our keyring, $3 = uri substring
  if [[ -f "$1" ]] && grep -qF "$2" "$1" 2>/dev/null &&
    grep -qF "$3" /etc/apt/sources.list 2>/dev/null; then
    vlog "$(basename "$1") clashes with /etc/apt/sources.list: removing it"
    as_root rm -f "$1"
  fi
}

# Overwriting a file that is already correct would invalidate apt's package lists.
write_if_changed() { # $1 = file to write from, $2 = where to write it
  if ((!DRY_RUN)) && as_root cmp -s "$2" "$1" 2>/dev/null; then
    vlog "$(basename "$2") already up to date"
  else
    as_root install -D -m 0644 "$1" "$2"
  fi
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# A dry-run on a machine without curl cannot fetch the signing keys, but the
# privileged steps are only printed anyway, so skipping the downloads is fine.
skip_downloads=0
if ((DRY_RUN)) && ! command -v curl >/dev/null 2>&1; then
  skip_downloads=1
  vlog "dry-run without curl: skipping the signing key downloads"
fi

# The SAS LGPL repo (flat './' repository).
if uri_known "$sas_host"; then
  vlog "the SAS repo is already an apt source: leaving it alone"
  drop_dup_list "$sas_list" "$sas_keyring" "$sas_host"
else
  if ((!skip_downloads)); then
    curl -fsSL --compressed "$sas_url/KEY.gpg" | gpg --dearmor >"$tmp/sas.key" ||
      die "could not download/dearmor the SAS signing key from $sas_url/KEY.gpg"
  fi
  printf 'deb [arch=%s signed-by=%s] %s ./\n' "$arch" "$sas_keyring" "$sas_url" >"$tmp/sas.list"
  write_if_changed "$tmp/sas.key" "$sas_keyring"
  write_if_changed "$tmp/sas.list" "$sas_list"
fi

# Gazebo stable (libgz-math7-dev, libsdformat14-dev).
if uri_known "$gazebo_host"; then
  vlog "the OSRF gazebo repo is already an apt source: leaving it alone"
  drop_dup_list "$gazebo_list" "$gazebo_keyring" "$gazebo_host"
else
  if ((!skip_downloads)); then
    curl -fsSL https://packages.osrfoundation.org/gazebo.gpg -o"$tmp/gazebo.key" ||
      die "could not download the OSRF signing key"
  fi
  printf 'deb [arch=%s signed-by=%s] %s %s main\n' \
    "$arch" "$gazebo_keyring" "$gazebo_url" "$codename" >"$tmp/gazebo.list"
  write_if_changed "$tmp/gazebo.key" "$gazebo_keyring"
  write_if_changed "$tmp/gazebo.list" "$gazebo_list"
fi

# The ros-jazzy-sas-* packages depend on ros-jazzy-* debs, so the ROS 2 repo
# must be configured too, e.g. on a machine that never had ROS 2. An existing
# ROS 2 apt source anywhere, such as ros2-apt-source or an entry kept in
# /etc/apt/sources.list from an older ROS 2 installation, makes this a no-op.
if uri_known "$ros_host"; then
  vlog "the ROS 2 repo is already an apt source: leaving it alone"
  drop_dup_list "$ros_list" "$ros_keyring" "$ros_host"
else
  if ((!skip_downloads)); then
    curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key |
      gpg --dearmor >"$tmp/ros.key" ||
      die "could not download/dearmor the ROS 2 signing key"
  fi
  printf 'deb [arch=%s signed-by=%s] %s %s main\n' \
    "$arch" "$ros_keyring" "$ros_url" "$codename" >"$tmp/ros.list"
  write_if_changed "$tmp/ros.key" "$ros_keyring"
  write_if_changed "$tmp/ros.list" "$ros_list"
fi

# libmarinholab-sas-core depends on libdqrobotics from the DQ Robotics
# development PPA. Any apt source that already points at that PPA, e.g. one
# added by an earlier 'add-apt-repository ppa:dqrobotics-dev/development',
# makes this step a no-op.
if uri_known "$dq_host"; then
  vlog "the DQ Robotics development PPA is already an apt source: leaving it alone"
  drop_dup_list "$dq_list" "$dq_keyring" "$dq_host"
else
  if ((!skip_downloads)); then
    curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x$dq_fingerprint" |
      gpg --dearmor >"$tmp/dq.key" ||
      die "could not download/dearmor the DQ Robotics PPA signing key ($dq_fingerprint)"
  fi
  printf 'deb [arch=%s signed-by=%s] %s %s main\n' \
    "$arch" "$dq_keyring" "$dq_url" "$codename" >"$tmp/dq.list"
  write_if_changed "$tmp/dq.key" "$dq_keyring"
  write_if_changed "$tmp/dq.list" "$dq_list"
fi

apt_run update -q || die "apt-get update failed: check the network and the apt sources above"

# --- Packages ----------------------------------------------------------------
sas_package_names() {
  apt-cache pkgnames "ros-${distro}-sas-" 2>/dev/null | grep -E "^ros-${distro}-sas-"
}

# Expand ros-jazzy-sas-* here instead of handing the glob to apt: apt reads an
# install argument as a regex, which would also pull in the -dbgsym packages.
mapfile -t packages < <(sas_package_names | grep -Ev -- '-dbgsym$' | sort -u)
if ((${#packages[@]} == 0)); then
  if ((DRY_RUN)); then
    log "dry-run: would install the ros-${distro}-sas-* packages (no package list cached to expand)"
    exit 0
  fi
  die "no ros-${distro}-sas-* packages in any configured apt source. Is '$distro' published under $sas_url?"
fi
if [[ "$SAS_DBGSYM" == 1 ]]; then
  mapfile -t dbgsym_packages < <(sas_package_names | grep -E -- '-dbgsym$' | sort -u)
  packages+=("${dbgsym_packages[@]}")
fi

packages+=(libgz-math7-dev libsdformat14-dev)
log "installing ${#packages[@]} package(s): ${packages[*]}"

# Mirrors (especially packages.osrfoundation.org) fail downloads from time to
# time; apt-get install is safe to repeat, so give it a few attempts.
attempts=0
until apt_run install -y "${packages[@]}"; do
  ((++attempts))
  if ((attempts >= 3)); then
    die "package installation failed after 3 attempts: check the network and the SAS, ROS 2, OSRF and DQ Robotics apt sources above"
  fi
  log "install attempt $attempts failed; retrying in $((attempts * 5))s"
  sleep $((attempts * 5))
done

if ((DRY_RUN)); then
  log "dry-run complete: nothing was changed."
else
  log "done: SAS installed for ROS 2 '$distro'."
fi
