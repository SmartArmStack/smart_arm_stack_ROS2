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

# --- Prerequisites -----------------------------------------------------------
missing=()
for tool in curl gpg dpkg apt-cache; do
  command -v "$tool" >/dev/null 2>&1 || missing+=("$tool")
done
((${#missing[@]} == 0)) ||
  die "missing required tool(s): ${missing[*]}. Install them first, e.g.: ${SUDO_PREFIX}apt-get install -y curl gnupg dpkg apt"

if [[ ! -t 0 && -z "${DEBIAN_FRONTEND:-}" ]]; then
  export DEBIAN_FRONTEND=noninteractive
  vlog "no tty: DEBIAN_FRONTEND=noninteractive"
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
gazebo_url="http://packages.osrfoundation.org/gazebo/ubuntu-stable"
sas_keyring=/etc/apt/keyrings/smartarmstack.gpg
gazebo_keyring=/etc/apt/keyrings/gazebo-stable.gpg

# Prefer the file an earlier run already wrote, so that two entries for the same
# URI cannot end up with different Signed-By values and break apt-get update.
existing_source_for() {
  local host="${1#*://}"
  grep -rlF "${host%/}" /etc/apt/sources.list.d/*.list 2>/dev/null | head -n 1 || true
}

sas_source="$(existing_source_for "$sas_url")"
sas_source="${sas_source:-/etc/apt/sources.list.d/smartarmstack.list}"
gazebo_source="$(existing_source_for "$gazebo_url")"
gazebo_source="${gazebo_source:-/etc/apt/sources.list.d/gazebo-stable.list}"
if [[ -f "$sas_source" ]]; then vlog "reusing the existing apt source file $sas_source"; fi
if [[ -f "$gazebo_source" ]]; then vlog "reusing the existing apt source file $gazebo_source"; fi

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

curl -fsSL --compressed "$sas_url/KEY.gpg" | gpg --dearmor >"$tmp/sas.key" ||
  die "could not download/dearmor the SAS signing key from $sas_url/KEY.gpg"
printf 'deb [arch=%s signed-by=%s] %s ./\n' "$arch" "$sas_keyring" "$sas_url" >"$tmp/sas.list"

curl -fsSL https://packages.osrfoundation.org/gazebo.gpg -o"$tmp/gazebo.key" ||
  die "could not download the OSRF signing key"
printf 'deb [arch=%s signed-by=%s] %s %s main\n' \
  "$arch" "$gazebo_keyring" "$gazebo_url" "$codename" >"$tmp/gazebo.list"

write_if_changed "$tmp/sas.key" "$sas_keyring"
write_if_changed "$tmp/sas.list" "$sas_source"
write_if_changed "$tmp/gazebo.key" "$gazebo_keyring"
write_if_changed "$tmp/gazebo.list" "$gazebo_source"

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

apt_run install -y "${packages[@]}" ||
  die "package installation failed: check the SAS and OSRF apt sources above"

if ((DRY_RUN)); then
  log "dry-run complete: nothing was changed."
else
  log "done: SAS installed for ROS 2 '$distro'."
fi
