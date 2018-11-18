#!/bin/bash

SOURCE_DIR=${PWD}/source
BUILD_DIR=${PWD}/build
OUTPUT_DIR=${PWD}/output


COLOR_STATUS=$'\033[1m\033[32m'
COLOR_RESET=$'\033[0m'

show_status() {
  echo "$COLOR_STATUS=> $1$COLOR_RESET"
}

mkdir -p $SOURCE_DIR
mkdir -p $BUILD_DIR
mkdir -p $OUTPUT_DIR

shopt -s nullglob

show_status "Downloading sources"

download_repo() {
  show_status "Downloading $2"
  if [ -d $SOURCE_DIR/$1 ]; then
    pushd $SOURCE_DIR/$1
    git pull
    git submodule update
    popd
  else
    git clone --recursive $2 $SOURCE_DIR/$1
  fi
}

download_repo msa https://github.com/minecraft-linux/msa-manifest.git
download_repo mcpelauncher https://github.com/minecraft-linux/mcpelauncher-manifest.git
download_repo mcpelauncher-ui https://github.com/minecraft-linux/mcpelauncher-ui-manifest.git

build_component() {
  show_status "Building $1"
  mkdir -p $BUILD_DIR/$1
  pushd $BUILD_DIR/$1
  cmake $CMAKE_OPTIONS $SOURCE_DIR/$1
  make -j$(nproc)
  popd
  pushd $OUTPUT_DIR
  for cf in $BUILD_DIR/$1/**/CPackConfig.cmake; do
    echo "CPack config: $cf"
    cpack --config $cf
  done
  popd
}

CMAKE_OPTIONS=-DENABLE_MSA_QT_UI=ON -DMSA_UI_PATH_DEV=OFF
build_component msa
CMAKE_OPTIONS=
build_component mcpelauncher
build_component mcpelauncher-ui

rm -rf $OUTPUT_DIR/_CPack_Packages
