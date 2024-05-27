#!/usr/bin/env bash
# Copyright 2017-2023 @polkadot/apps authors & contributors
# This software may be modified and distributed under the terms
# of the Apache-2.0 license. See the LICENSE file for details.

# fail fast on any non-zero exits
set -e

# the docker image name and dockerhub repo
source docker/.env

# extract the current npm version from package.json
IMAGE_VERSION=$(cat package.json \
  | grep version \
  | head -1 \
  | awk -F: '{ print $2 }' \
  | sed 's/[",]//g' \
  | sed 's/ //g')

echo "*** Building $NAME"
docker compose -f docker/docker-compose.yaml build 

docker login -u $IMAGE_REPO -p $DOCKER_PASS

echo "*** Tagging $IMAGE_REPO/$IMAGE_NAME"
if [[ $IMAGE_VERSION != *"beta"* ]]; then
  docker tag $IMAGE_NAME $IMAGE_REPO/$IMAGE_NAME:$IMAGE_VERSION
fi
docker tag $IMAGE_NAME $IMAGE_REPO/$IMAGE_NAME

echo "*** Publishing $IMAGE_REPO/$IMAGE_NAME"
docker push $IMAGE_REPO/$IMAGE_NAME
