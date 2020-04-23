#!/bin/bash

SOURCE_DIR=${PWD}/source
BUILD_DIR=${PWD}/build
OUTPUT_DIR=${PWD}/output

MAKE_JOBS=$(nproc)

COLOR_STATUS=$'\033[1m\033[32m'
COLOR_RESET=$'\033[0m'

show_status() {
  echo "$COLOR_STATUS=> $1$COLOR_RESET"
}
check_run() {
  $@
  local STATUS=$?
  if (( $STATUS != 0 )); then
    exit $STATUS
  fi
}

shopt -s nullglob

load_quirks() {
  if [ ! -z "$1" ]; then
    show_status "Loading quirks file: $1"
    source "$1"
  fi
}

call_quirk() {
  local QUIRK_NAME="quirk_$1"
  QUIRK_NAME=`declare -f -F "$QUIRK_NAME"`
  if (( $? == 0 )); then
    show_status "Executing $QUIRK_NAME"
    $QUIRK_NAME
  fi
}

create_build_directories() {
  mkdir -p $SOURCE_DIR
  mkdir -p $BUILD_DIR
  mkdir -p $OUTPUT_DIR
}

download_repo() {
  show_status "Downloading $2"
  if [ -d $SOURCE_DIR/$1 ]; then
    pushd $SOURCE_DIR/$1
    check_run git pull
    check_run git submodule update
    popd
  else
    check_run git clone --recursive -b $3 $2 $SOURCE_DIR/$1
  fi
}

reset_cmake_options() {
  CMAKE_OPTIONS=()
}

add_cmake_options() {
  CMAKE_OPTIONS=("${CMAKE_OPTIONS[@]}" "$@")
}

build_component() {
  show_status "Building $1"
  mkdir -p $BUILD_DIR/$1
  pushd $BUILD_DIR/$1
  echo "cmake" $CMAKE_OPTIONS "$SOURCE_DIR/$1"
  cmake "${CMAKE_OPTIONS[@]}" "$SOURCE_DIR/$1"
  check_run make -j${MAKE_JOBS}
  popd
}
install_component_cpack() {
  pushd $OUTPUT_DIR
  for cf in $BUILD_DIR/$1/**/CPackConfig.cmake; do
    echo "CPack config: $cf"
    check_run cpack --config $cf
  done
  popd
}

cleanup_build() {
  rm -rf $OUTPUT_DIR/_CPack_Packages
}
