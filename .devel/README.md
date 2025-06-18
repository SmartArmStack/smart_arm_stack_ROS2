# MacOS Setup

Because these are system-level packages, `brew install` isn't enough.

- Install docker desktop from
  https://www.docker.com/products/docker-desktop/

- Open and login

```commandline
docker buildx build -t sas_deb_builder --platform=linux/amd64 sas_deb_builder
```


## Failed attempts

With brew, I was either unable to login or got the error below. After installing from docker desktop the version
was clearly different so that might have been the issue.

```commandline
Error response from daemon: Get "https://registry-1.docker.io/v2/": rejecting registry-1.docker.io:443 because traffic from evaluating PAC file: getting PAC interpreter: Get "http://wpad/wpad.dat": dial tcp: lookup wpad: no such host
```

```commandline
brew install --cask docker
brew install --cask xquartz
```


