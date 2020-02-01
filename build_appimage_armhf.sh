#!/bin/bash

source common.sh

QUIRKS_FILE=
APP_DIR=${BUILD_DIR}/AppDir
UPDATE_CMAKE_OPTIONS=""

while getopts "h?q:j:u:i:" opt; do
    case "$opt" in
    h|\?)
        echo "build.sh"
        echo "-j  Specify the number of jobs (the -j arg to make)"
        echo "-q  Specify the quirks file"
        echo "-u  Specify the update check URL"
        echo "-i  Specify the build id for update checking"
        exit 0
        ;;
    j)  MAKE_JOBS=$OPTARG
        ;;
    q)  QUIRKS_FILE=$OPTARG
        ;;
    u)  UPDATE_CMAKE_OPTIONS="$UPDATE_CMAKE_OPTIONS -DENABLE_UPDATE_CHECK=ON -DUPDATE_CHECK_URL=$OPTARG"
        ;;
    i)  UPDATE_CMAKE_OPTIONS="$UPDATE_CMAKE_OPTIONS -DUPDATE_CHECK_BUILD_ID=$OPTARG"
        ;;
    esac
done

load_quirks "$QUIRKS_FILE"

create_build_directories
rm -rf ${APP_DIR}
mkdir -p ${APP_DIR}
call_quirk init

show_status "Downloading sources"
download_repo deb2appimage https://github.com/ChristopherHX/deb2appimage.git
download_repo mcpelauncher-deb2appimage https://github.com/ChristopherHX/mcpelauncher-deb2appimage.git
download_repo msa https://github.com/minecraft-linux/msa-manifest.git
download_repo mcpelauncher https://github.com/ChristopherHX/mcpelauncher-manifest.git
download_repo mcpelauncher-ui https://github.com/ChristopherHX/mcpelauncher-ui-manifest.git

call_quirk build_start

install_component() {
  pushd $OUTPUT_DIR
  check_run cpack --config ${BUILD_DIR}/$1/$2/CPackConfig.cmake
  popd
}

build_component2() {
  show_status "Building $1"
  mkdir -p $BUILD_DIR/$1
  pushd $BUILD_DIR/$1
  echo "cmake" $CMAKE_OPTIONS "$SOURCE_DIR/$1"
  check_run cmake $CMAKE_OPTIONS "$SOURCE_DIR/$1"
  sed -i 's/x86_64-linux-gnu/arm-linux-gnueabihf/g' CMakeCache.txt
  check_run make -j${MAKE_JOBS}
  popd
}

reset_cmake_options
add_cmake_options -DCMAKE_INSTALL_PREFIX=/usr -DENABLE_MSA_QT_UI=ON -DMSA_UI_PATH_DEV=OFF -DCMAKE_TOOLCHAIN_FILE=${OUTPUT_DIR}/../armhftoolchain.txt -DCPACK_DEBIAN_PACKAGE_ARCHITECTURE=armhf -DCMAKE_CXX_FLAGS=-latomic
call_quirk build_msa
build_component2 msa
install_component msa msa-ui-qt
install_component msa msa-daemon
reset_cmake_options
add_cmake_options -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_TOOLCHAIN_FILE=${OUTPUT_DIR}/../armhftoolchain.txt -DCPACK_DEBIAN_PACKAGE_ARCHITECTURE=armhf -DCMAKE_CXX_FLAGS=-latomic -DMSA_DAEMON_PATH=.
call_quirk build_mcpelauncher
pushd $SOURCE_DIR/mcpelauncher/mcpelauncher-linux-bin
git checkout armhf
popd
pushd $SOURCE_DIR/mcpelauncher/minecraft-symbols/tools
python3 ./process_headers.py --armhf
popd
build_component2 mcpelauncher
install_component mcpelauncher mcpelauncher-client
reset_cmake_options
add_cmake_options -DCMAKE_INSTALL_PREFIX=/usr -DGAME_LAUNCHER_PATH=. $UPDATE_CMAKE_OPTIONS -DCMAKE_TOOLCHAIN_FILE=${OUTPUT_DIR}/../armhftoolchain.txt -DCPACK_DEBIAN_PACKAGE_ARCHITECTURE=armhf -DCMAKE_CXX_FLAGS=-latomic
call_quirk build_mcpelauncher_ui
build_component2 mcpelauncher-ui
install_component mcpelauncher-ui mcpelauncher-ui-qt

show_status "Packaging"
pushd ${SOURCE_DIR}/mcpelauncher-deb2appimage
check_run ./updatearmhf.sh
${SOURCE_DIR}/deb2appimage/deb2appimage.sh -j config-buster-armhf.json -o ${OUTPUT_DIR}
popd

cleanup_build
