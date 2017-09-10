#!/bin/bash

set -ev

if test "x$DO_DOCKER_BUILD" = xyes && test "x$IS_DOCKER_BUILD" = xyes && test -n "$DOCKER_USERNAME" && test "x$DOCKER_TAR" = xfalse; then
  if [[ "$BUILD" == "autotools" && "$LLVM_VERSION" == "3.9" && "$TRAVIS_PULL_REQUEST" == "false" && "${TRAVIS_BRANCH%%/*}" == "pre-release" || "${TRAVIS_BRANCH%%/*}" == "released" ]]; then
    docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD";
    docker push "$DOCKER_REPOSITORY"/"$DOCKER_IMAGE_NAME":${TRAVIS_BRANCH%%/*}-${TRAVIS_BRANCH##*/}$(${DOCKER_DEBUG:-false} && printf ".debug");
  fi;

  if [[ "$BUILD" == "distcheck" && "$TRAVIS_PULL_REQUEST" == "false" ]]; then
    docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD";
    docker push "$DOCKER_REPOSITORY"/"$DOCKER_IMAGE_NAME":${TRAVIS_BRANCH%%/*}-${TRAVIS_BRANCH##*/}.distcheck;
  fi
fi
