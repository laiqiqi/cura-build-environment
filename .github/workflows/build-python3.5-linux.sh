#!/bin/bash

set -e

GIT_REF="$(basename "${GIT_REF}")"
TAG="python3.5-${GIT_REF}"

# Only tag as the latest for master
if [ "${GIT_REF}" = "master" ]; then
  if [ -z "${DOCKER_IMAGE_LATEST_TAG}" ]; then
    echo "DOCKER_IMAGE_LATEST_TAG environment variable is missing. It's expected from GitHub workflow file."
    exit 1
  fi
  EXTRA_TAG="${DOCKER_IMAGE_LATEST_TAG}"
fi

# Build the image
docker build -t "${DOCKER_IMAGE_NAME}:${TAG}" -f docker/python3.5/linux/Dockerfile .
if [ -n "${EXTRA_TAG}" ]; then
  docker tag "${DOCKER_IMAGE_NAME}:${TAG}" "${DOCKER_IMAGE_NAME}:${EXTRA_TAG}"
fi

# Docker login and push image
echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USER}" --password-stdin "${DOCKER_IO}"
docker push "${DOCKER_IMAGE_NAME}:${TAG}"
if [ -n "${EXTRA_TAG}" ]; then
  docker push "${DOCKER_IMAGE_NAME}:${EXTRA_TAG}"
fi
docker logout