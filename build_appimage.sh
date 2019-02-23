#!/bin/bash

source common.sh

QUIRKS_FILE=
APP_DIR=${BUILD_DIR}/AppDir

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

load_quirks "$QUIRKS_FILE"

create_build_directories
rm -rf ${APP_DIR}
mkdir -p ${APP_DIR}
call_quirk init

show_status "Downloading sources"
download_repo msa https://github.com/minecraft-linux/msa-manifest.git
download_repo mcpelauncher https://github.com/minecraft-linux/mcpelauncher-manifest.git
download_repo mcpelauncher-ui https://github.com/minecraft-linux/mcpelauncher-ui-manifest.git

call_quirk build_start

install_component() {
  pushd $BUILD_DIR/$1
  check_run make install DESTDIR="${APP_DIR}"
  popd
}

reset_cmake_options
add_cmake_options -DCMAKE_INSTALL_PREFIX=/usr -DENABLE_MSA_QT_UI=ON -DMSA_UI_PATH_DEV=OFF
call_quirk build_msa
build_component msa
install_component msa
reset_cmake_options
add_cmake_options -DCMAKE_INSTALL_PREFIX=/usr
call_quirk build_mcpelauncher
build_component mcpelauncher
install_component mcpelauncher
reset_cmake_options
add_cmake_options -DCMAKE_INSTALL_PREFIX=/usr -DGAME_LAUNCHER_PATH=.
call_quirk build_mcpelauncher_ui
build_component mcpelauncher-ui
install_component mcpelauncher-ui

cp $SOURCE_DIR/mcpelauncher-ui/mcpelauncher-ui-qt/Resources/proprietary/mcpelauncher-icon-512.png $BUILD_DIR/mcpelauncher-ui-qt.png
cp $SOURCE_DIR/mcpelauncher-ui/mcpelauncher-ui-qt/mcpelauncher-ui-qt.desktop $BUILD_DIR/mcpelauncher-ui-qt.desktop

# download linuxdeploy and make it executable
wget -N https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
# also download Qt plugin, which is needed for the Qt UI
wget -N https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage

chmod +x linuxdeploy*-x86_64.AppImage

export ARCH=x86_64

mkdir linuxdeploy
cd linuxdeploy
../linuxdeploy-x86_64.AppImage --appimage-extract
cd ..
mkdir linuxdeploy-plugin-qt
cd linuxdeploy-plugin-qt
../linuxdeploy-plugin-qt-x86_64.AppImage --appimage-extract
cd ..
LINUXDEPLOY_BIN=linuxdeploy/squashfs-root/AppRun
LINUXDEPLOY_PLUGIN_QT_BIN=linuxdeploy-plugin-qt/squashfs-root/AppRun

$LINUXDEPLOY_BIN --appdir $APP_DIR -i $BUILD_DIR/mcpelauncher-ui-qt.png -d $BUILD_DIR/mcpelauncher-ui-qt.desktop

export QML_SOURCES_PATHS=ui/mcpelauncher-ui-qt/qml/
$LINUXDEPLOY_PLUGIN_QT_BIN --appdir AppDir

$LINUXDEPLOY_BIN --appdir $APP_DIR --output appimage

cleanup_build
