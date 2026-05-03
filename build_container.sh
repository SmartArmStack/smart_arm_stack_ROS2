#!/bin/bash
set -e
docker buildx build -t $1 $1 --build-context sas_repo=./ --progress=plain