#!/bin/bash

SOURCE_DIR=${PWD}/source
BUILD_DIR=${PWD}/build
OUTPUT_DIR=${PWD}/output

MAKE_JOBS=$(nproc)
QUIRKS_FILE=

while getopts "h?q:j:" opt; do
    case "$opt" in
    h|\?)
        echo "build.sh"
        echo "-j  Specify the number of jobs (the -j arg to make)"
        echo "-q  Specify the quirks file"
        exit 0
        ;;
    j)  MAKE_JOBS=$OPTARG
        ;;
    q)  QUIRKS_FILE=$OPTARG
        ;;
    esac
done

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

if [ ! -z "$QUIRKS_FILE" ]; then
  show_status "Loading quirks file: $QUIRKS_FILE"
  source $QUIRKS_FILE
fi

call_quirk() {
  local QUIRK_NAME="quirk_$1"
  QUIRK_NAME=`declare -f -F "$QUIRK_NAME"`
  if (( $? == 0 )); then
    show_status "Executing $QUIRK_NAME"
    $QUIRK_NAME
  fi
}

mkdir -p $SOURCE_DIR
mkdir -p $BUILD_DIR
mkdir -p $OUTPUT_DIR

call_quirk init

show_status "Downloading sources"

download_repo() {
  show_status "Downloading $2"
  if [ -d $SOURCE_DIR/$1 ]; then
    pushd $SOURCE_DIR/$1
    check_run git pull
    check_run git submodule update
    popd
  else
    check_run git clone --recursive $2 $SOURCE_DIR/$1
  fi
}

download_repo msa https://github.com/minecraft-linux/msa-manifest.git
download_repo mcpelauncher https://github.com/minecraft-linux/mcpelauncher-manifest.git
download_repo mcpelauncher-ui https://github.com/minecraft-linux/mcpelauncher-ui-manifest.git

reset_cmake_options() {
  CMAKE_OPTIONS=
}
add_cmake_options() {
  CMAKE_OPTIONS="$CMAKE_OPTIONS $@"
}
build_component() {
  show_status "Building $1"
  mkdir -p $BUILD_DIR/$1
  pushd $BUILD_DIR/$1
  echo "cmake" $CMAKE_OPTIONS "$SOURCE_DIR/$1"
  check_run cmake $CMAKE_OPTIONS "$SOURCE_DIR/$1"
  check_run make -j${MAKE_JOBS}
  popd
  pushd $OUTPUT_DIR
  for cf in $BUILD_DIR/$1/**/CPackConfig.cmake; do
    echo "CPack config: $cf"
    check_run cpack --config $cf
  done
  popd
}

call_quirk build_start

reset_cmake_options
add_cmake_options -DENABLE_MSA_QT_UI=ON -DMSA_UI_PATH_DEV=OFF
call_quirk build_msa
build_component msa
reset_cmake_options
call_quirk build_mcpelauncher
build_component mcpelauncher
reset_cmake_options
call_quirk build_mcpelauncher_ui
build_component mcpelauncher-ui

rm -rf $OUTPUT_DIR/_CPack_Packages
