#!/bin/bash
set -e
docker buildx build -t $1 $1