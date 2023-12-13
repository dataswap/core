#!/usr/bin/env bash

VERSION=$(git ls-remote --tags https://github.com/dataswap/core.git | awk '{print $2}' | grep -v '{}' | awk -F '/' '{print $3}' | sort -V | tail -n 1 | sed 's/^v//')

IMAGE_NAME="dataswap/lotus-devnet"

docker build -t $IMAGE_NAME:$VERSION . 

docker push $IMAGE_NAME:$VERSION