#!/bin/bash

source common.sh

QUIRKS_FILE=
APP_DIR=${BUILD_DIR}/AppDir
UPDATE_CMAKE_OPTIONS=""
BUILD_NUM="0"

while getopts "h?q:j:u:i:k:" opt; do
    case "$opt" in
    h|\?)
        echo "build.sh"
        echo "-j  Specify the number of jobs (the -j arg to make)"
        echo "-q  Specify the quirks file"
        echo "-u  Specify the update check URL"
        echo "-i  Specify the build id for update checking"
        echo "-k  Specify appimageupdate information"
        exit 0
        ;;
    j)  MAKE_JOBS=$OPTARG
        ;;
    q)  QUIRKS_FILE=$OPTARG
        ;;
    u)  UPDATE_CMAKE_OPTIONS="$UPDATE_CMAKE_OPTIONS -DENABLE_UPDATE_CHECK=ON -DUPDATE_CHECK_URL=$OPTARG"
        ;;
    i)  UPDATE_CMAKE_OPTIONS="$UPDATE_CMAKE_OPTIONS -DUPDATE_CHECK_BUILD_ID=$OPTARG"
        BUILD_NUM="${OPTARG}"
        ;;
    k)  UPDATE_CMAKE_OPTIONS="$UPDATE_CMAKE_OPTIONS -DENABLE_APPIMAGE_UPDATE_CHECK=1"
        export UPDATE_INFORMATION="$OPTARG"
        ;;
    esac
done

load_quirks "$QUIRKS_FILE"

create_build_directories
rm -rf ${APP_DIR}
mkdir -p ${APP_DIR}
call_quirk init

show_status "Downloading sources"
download_repo msa https://github.com/minecraft-linux/msa-manifest.git master
download_repo mcpelauncher https://github.com/minecraft-linux/mcpelauncher-manifest.git ng
download_repo mcpelauncher-ui https://github.com/minecraft-linux/mcpelauncher-ui-manifest.git ng
mkdir -p "$SOURCE_DIR/mcpelauncher-ui/lib/AppImageUpdate"
git clone --recursive https://github.com/AppImage/AppImageUpdate "$SOURCE_DIR/mcpelauncher-ui/lib/AppImageUpdate" || cd "$SOURCE_DIR/mcpelauncher-ui/lib/AppImageUpdate" && git pull && git submodule update --init --recursive

call_quirk build_start

install_component() {
  pushd $BUILD_DIR/$1
  check_run make install DESTDIR="${APP_DIR}"
  popd
}

build_component32() {
  show_status "Building $1"
  mkdir -p $BUILD_DIR/$1
  pushd $BUILD_DIR/$1
  echo "cmake" "${CMAKE_OPTIONS[@]}" "$SOURCE_DIR/$1"
  check_run cmake "${CMAKE_OPTIONS[@]}" "$SOURCE_DIR/$1"
  sed -i 's/\/usr\/lib\/x86_64-linux-gnu/\/usr\/lib\/i386-linux-gnu/g' CMakeCache.txt
  check_run make -j${MAKE_JOBS}
  popd
}

reset_cmake_options
add_cmake_options -DCMAKE_INSTALL_PREFIX=/usr -DENABLE_MSA_QT_UI=ON -DMSA_UI_PATH_DEV=OFF
call_quirk build_msa
build_component msa
install_component msa
reset_cmake_options
add_cmake_options -DCMAKE_INSTALL_PREFIX=/usr -DMSA_DAEMON_PATH=. -DENABLE_QT_ERROR_UI=OFF
call_quirk build_mcpelauncher
build_component mcpelauncher
install_component mcpelauncher
reset_cmake_options
add_cmake_options -DCMAKE_INSTALL_PREFIX=/usr -DGAME_LAUNCHER_PATH=. $UPDATE_CMAKE_OPTIONS
call_quirk build_mcpelauncher_ui

build_component mcpelauncher-ui
install_component mcpelauncher-ui

show_status "Packaging"

cp $SOURCE_DIR/mcpelauncher-ui/mcpelauncher-ui-qt/Resources/proprietary/mcpelauncher-icon-512.png $BUILD_DIR/mcpelauncher-ui-qt.png
cp $SOURCE_DIR/mcpelauncher-ui/mcpelauncher-ui-qt/mcpelauncher-ui-qt.desktop $BUILD_DIR/mcpelauncher-ui-qt.desktop

# download linuxdeploy and make it executable
wget -N https://artifacts.assassinate-you.net/linuxdeploy/travis-456/linuxdeploy-i386.AppImage
# also download Qt plugin, which is needed for the Qt UI
wget -N https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-i386.AppImage

chmod +x linuxdeploy*-i386.AppImage

export ARCH=i386

mkdir linuxdeploy
cd linuxdeploy
../linuxdeploy-i386.AppImage --appimage-extract
cd ..
mkdir linuxdeploy-plugin-qt
cd linuxdeploy-plugin-qt
../linuxdeploy-plugin-qt-i386.AppImage --appimage-extract
cd ..
LINUXDEPLOY_BIN=linuxdeploy/squashfs-root/AppRun
LINUXDEPLOY_PLUGIN_QT_BIN=linuxdeploy-plugin-qt/squashfs-root/AppRun

check_run $LINUXDEPLOY_BIN --appdir $APP_DIR -i $BUILD_DIR/mcpelauncher-ui-qt.png -d $BUILD_DIR/mcpelauncher-ui-qt.desktop

export QML_SOURCES_PATHS=$SOURCE_DIR/mcpelauncher-ui/mcpelauncher-ui-qt/qml/:$SOURCE_DIR/mcpelauncher/mcpelauncher-webview
check_run $LINUXDEPLOY_PLUGIN_QT_BIN --appdir $APP_DIR

cp -r /usr/lib/i386-linux-gnu/nss $APP_DIR/usr/lib/
curl  https://curl.haxx.se/ca/cacert.pem --output $APP_DIR/usr/share/mcpelauncher/cacert.pem

export OUTPUT="Minecraft_Bedrock_Launcher-${ARCH}.0.0.${BUILD_NUM}.AppImage"
check_run $LINUXDEPLOY_BIN --appdir $APP_DIR --output appimage
mv Minecraft*.AppImage output
mv *.zsync output/version.${ARCH}.zsync

cleanup_build
