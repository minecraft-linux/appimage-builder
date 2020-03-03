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
download_repo msa https://github.com/minecraft-linux/msa-manifest.git
download_repo mcpelauncher https://github.com/ChristopherHX/mcpelauncher-manifest.git
download_repo mcpelauncher-ui https://github.com/ChristopherHX/mcpelauncher-ui-manifest.git

call_quirk build_start

install_component() {
  pushd $BUILD_DIR/$1
  check_run make install DESTDIR="${APP_DIR}"
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
install_component msa
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
install_component mcpelauncher
reset_cmake_options
add_cmake_options -DCMAKE_INSTALL_PREFIX=/usr -DGAME_LAUNCHER_PATH=. $UPDATE_CMAKE_OPTIONS -DCMAKE_TOOLCHAIN_FILE=${OUTPUT_DIR}/../armhftoolchain.txt -DCPACK_DEBIAN_PACKAGE_ARCHITECTURE=armhf -DCMAKE_CXX_FLAGS=-latomic
call_quirk build_mcpelauncher_ui
pushd $SOURCE_DIR/mcpelauncher-ui/playdl-signin-ui-qt
check_run git checkout master
popd
build_component2 mcpelauncher-ui
install_component mcpelauncher-ui

show_status "Packaging"

cp $SOURCE_DIR/mcpelauncher-ui/mcpelauncher-ui-qt/Resources/proprietary/mcpelauncher-icon-512.png $BUILD_DIR/mcpelauncher-ui-qt.png
cp $SOURCE_DIR/mcpelauncher-ui/mcpelauncher-ui-qt/mcpelauncher-ui-qt.desktop $BUILD_DIR/mcpelauncher-ui-qt.desktop

# download linuxdeploy and make it executable
wget -N https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-i386.AppImage
# also download Qt plugin, which is needed for the Qt UI
wget -N https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-i386.AppImage

wget -N https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage

wget -N https://github.com/AppImage/AppImageKit/releases/download/continuous/runtime-armhf

chmod +x linuxdeploy*-i386.AppImage
chmod +x appimagetool*.AppImage

export ARCH=armhf

mkdir linuxdeploy
cd linuxdeploy
../linuxdeploy-i386.AppImage --appimage-extract
# fix arm
rm -rf squashfs-root/usr/bin/strip squashfs-root/usr/bin/readelf
ln -s /usr/arm-linux-gnueabihf/bin/readelf squashfs-root/usr/bin/readelf
echo '#!/bin/bash' > squashfs-root/usr/bin/strip
chmod +x squashfs-root/usr/bin/strip
cd ..
mkdir linuxdeploy-plugin-qt
cd linuxdeploy-plugin-qt
../linuxdeploy-plugin-qt-i386.AppImage --appimage-extract
# fix arm
rm -rf squashfs-root/usr/bin/strip squashfs-root/usr/bin/readelf
ln -s /usr/arm-linux-gnueabihf/bin/readelf squashfs-root/usr/bin/readelf
echo '#!/bin/bash' > squashfs-root/usr/bin/strip
chmod +x squashfs-root/usr/bin/strip
cd ..cd ..
mkdir appimagetool
cd appimagetool
../appimagetool-x86_64.AppImage --appimage-extract
cd ..
LINUXDEPLOY_BIN=linuxdeploy/squashfs-root/AppRun
LINUXDEPLOY_PLUGIN_QT_BIN=linuxdeploy-plugin-qt/squashfs-root/AppRun
APPIMAGETOOL_BIN=appimagetool/squashfs-root/AppRun

check_run $LINUXDEPLOY_BIN --appdir $APP_DIR -i $BUILD_DIR/mcpelauncher-ui-qt.png -d $BUILD_DIR/mcpelauncher-ui-qt.desktop

export QML_SOURCES_PATHS=$SOURCE_DIR/mcpelauncher-ui/mcpelauncher-ui-qt/qml/
check_run $LINUXDEPLOY_PLUGIN_QT_BIN --appdir $APP_DIR

cp -r /usr/lib/arm-linux-gnuabihf/nss $APP_DIR/usr/lib/

check_run $APPIMAGETOOL_BIN --runtime-file runtime-armhf $APP_DIR Minecraft_Bedrock_Launcher-latest-armhf.AppImage
mv Minecraft*.AppImage output

cleanup_build
