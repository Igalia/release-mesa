#!/bin/bash

set -ev

if test "x$DO_DOCKER_BUILD" = xyes && test "x$IS_DOCKER_BUILD" = xyes; then
  wget "$ROCKERFILES_BASE_URL"/"$ROCKERFILE_MESA";
  wget https://github.com/grammarly/rocker/releases/download/1.3.1/rocker-1.3.1-linux_amd64.tar.gz;
  tar xvf rocker-1.3.1-linux_amd64.tar.gz;
  rm rocker-1.3.1-linux_amd64.tar.gz;
  mkdir -p -m777 ~/.ccache;
fi
