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
# download_repo curl https://github.com/curl/curl.git master
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
  sed -i 's/\/usr\/lib\/x86_64-linux-gnu/\/usr\/lib\/arm-linux-gnueabihf/g' CMakeCache.txt
  sed -i 's/\/usr\/include\/x86_64-linux-gnu/\/usr\/include\/arm-linux-gnueabihf/g' CMakeCache.txt
  check_run make -j${MAKE_JOBS}
  popd
}

# reset_cmake_options
# add_cmake_options -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_TOOLCHAIN_FILE=${OUTPUT_DIR}/../armhftoolchain.txt -DCMAKE_C_COMPILER=/usr/bin/arm-linux-gnueabihf-gcc -DCMAKE_CXX_COMPILER=/usr/bin/arm-linux-gnueabihf-g++
# build_component32 curl
# install_component curl

reset_cmake_options
add_cmake_options -DCMAKE_INSTALL_PREFIX=/usr -DENABLE_MSA_QT_UI=ON -DMSA_UI_PATH_DEV=OFF -DCMAKE_TOOLCHAIN_FILE=${OUTPUT_DIR}/../armhftoolchain.txt -DCPACK_DEBIAN_PACKAGE_ARCHITECTURE=armhf -DCMAKE_ASM_FLAGS="--target=arm-linux-gnueabihf -march=armv7 -mfpu=neon" -DCMAKE_C_FLAGS="-latomic --target=arm-linux-gnueabihf -march=armv7 -mfpu=neon" -DCMAKE_CXX_FLAGS="-latomic --target=arm-linux-gnueabihf -march=armv7 -mfpu=neon -DNDEBUG -I ${PWD}/curlappimageca" -DCURL_INCLUDE_DIRS="$APP_DIR/usr/include" -DCURL_LIBRARIES="$APP_DIR/usr/lib/libcurl.so"
call_quirk build_msa
build_component32 msa
install_component msa
reset_cmake_options
add_cmake_options -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_TOOLCHAIN_FILE=${OUTPUT_DIR}/../armhftoolchain.txt -DCPACK_DEBIAN_PACKAGE_ARCHITECTURE=armhf -DMSA_DAEMON_PATH=. -DCMAKE_ASM_FLAGS="--target=arm-linux-gnueabihf -march=armv7 -mfpu=neon" -DCMAKE_C_FLAGS="-latomic --target=arm-linux-gnueabihf -march=armv7 -mfpu=neon" -DCMAKE_CXX_FLAGS="-latomic --target=arm-linux-gnueabihf -march=armv7 -mfpu=neon -DNDEBUG -I ${PWD}/curlappimageca" -DJNI_USE_JNIVM=ON -DXAL_WEBVIEW_QT_PATH=. -DCURL_INCLUDE_DIRS="$APP_DIR/usr/include" -DCURL_LIBRARIES="$APP_DIR/usr/lib/libcurl.so"
call_quirk build_mcpelauncher
build_component32 mcpelauncher
install_component mcpelauncher
reset_cmake_options
add_cmake_options -DCMAKE_INSTALL_PREFIX=/usr -DGAME_LAUNCHER_PATH=. $UPDATE_CMAKE_OPTIONS -DCMAKE_TOOLCHAIN_FILE=${OUTPUT_DIR}/../armhftoolchain.txt -DCPACK_DEBIAN_PACKAGE_ARCHITECTURE=armhf -DCMAKE_ASM_FLAGS="--target=arm-linux-gnueabihf -march=armv7 -mfpu=neon" -DCMAKE_C_FLAGS="-latomic --target=arm-linux-gnueabihf -march=armv7 -mfpu=neon" -DCMAKE_CXX_FLAGS="-latomic --target=arm-linux-gnueabihf -march=armv7 -mfpu=neon -DNDEBUG -I ${PWD}/curlappimageca -DLAUNCHER_VERSION_NAME=\"\\\"Launcher 0.1-b1<br/>1.16.200 now working<br/>ng ported to arm and arm64<br/>A lot of UI and launcher changes<br/>Fixed internal storage<br/>Modding support disabled again in this beta release<br/><br/>0.1.p4-AppImage-x86.${BUILD_NUM}\\\"\" -DLAUNCHER_VERSION_CODE=${BUILD_NUM} -DLAUNCHER_CHANGE_LOG=\"\\\"Launcher 0.1-p4<br/>Technical changes to google play latest<br/>Fallback to launcher latest (beta) and hide latest,<br/>instead of disabling download and play<br/>if not found in the versionsdb<br/>allow incompatible => allowBeta, unsupported google play latest<br/>allowBeta only active if in beta program<br/><br/>Changes from 0.1.p2<br/>Remove gamepad input undefined behaviour, allways crashed if gamepad is connected<br/>Fix building for x86 32bit<br/>Fix changelog always shown (changed invalid type bool to int)<br/>Enhancement show arch in versionlist (Settings)<br/>Fix QSettings undefined behavior<br/>Enhancement keyboard navigation in versionslist (Settings)<br/>Fix cannot select google play latest anymore<br/>Changes from last preview<br/>Reenable hooking / modding support x86, x86_64 (new)<br/>Fix macOS 10.10 compatibility<br/>Fixed some crashs<br/>Fix gamepads<br/>Use same x11 window class for filepicker and gamewindow<br/>made x11 window class changeabi via cli<br/>Fix dlerror<br/>less linker logging<br/>Known issues:<br/><ul><li>msa-ui-qt doesn't get the correct window class yet, started by msa-daemon without `-name mcpelauncher` (Linux)</li><li>more crashs if gamepad is connected</li><li>resizeing the window lags</li><li>no visual errorreporting</li><li>crash if zenity isn't installed (Linux)</li><li>crash with random mutex lock fails (memory corruption)</li><li>apply glcorepatch on compatible versions with pattern / symbol, fallback to current behavior (primary macOS)</li><li>no armhf compat</li><li>No sound for aarch64, if you get that running</li><li>No sound for beta 1.16.0.67+, release 1.16.20+ (x86 / 32bit macOS)</li><li>a lot more..</li></ul><br/>Changes from flatpak-0.0.4><ul>    <li>Added Changelog</li>    <li>Fixed saving gamedata in Internal Storage. Please revert the previous workaround with 'flatpak --user --reset io.mrarm.mcpelauncher' or 'sudo flatpak --reset io.mrarm.mcpelauncher', then move the created '~/data/data/' folder to '~/.var/app/io.mrarm.mcpelauncher/data/mcpelauncher'</li>    <li>Minecraft 1.16.100.54 now working</li>    <li>Added Reset the Launcher via Settings</li>    <li>Added About Page with Version information</li>    <li>Added Compatibility report with more detailed Unsupported message</li>    <li>Extended the Troubleshooter to include more Items like the Compatibility Report</li>    <li>Moved again from fake-jni to libjnivm as fake java native interface</li>    <li>Also run 1.16.20 - 1.16.100 x86 variants</li>    <li>Block Google Play latest if it would be incompatible incl. Troubleshooter entry</li>    <li>Fix Google Play latest still hidden after login to the launcher</li>    <li>Improve integrated UpdateChecker to respond if you click on Check for Updates</li>    <li>Show error if update failed, instead of failing silently</li></ul>\\\"\"" -DQt5QuickCompiler_FOUND:BOOL=OFF -DCURL_INCLUDE_DIRS="$APP_DIR/usr/include" -DCURL_LIBRARIES="$APP_DIR/usr/lib/libcurl.so"
call_quirk build_mcpelauncher_ui

build_component32 mcpelauncher-ui
install_component mcpelauncher-ui

show_status "Packaging"

cp $SOURCE_DIR/mcpelauncher-ui/mcpelauncher-ui-qt/Resources/proprietary/mcpelauncher-icon-512.png $BUILD_DIR/mcpelauncher-ui-qt.png
cp $SOURCE_DIR/mcpelauncher-ui/mcpelauncher-ui-qt/mcpelauncher-ui-qt.desktop $BUILD_DIR/mcpelauncher-ui-qt.desktop

# download linuxdeploy and make it executable
wget -N https://artifacts.assassinate-you.net/artifactory/list/linuxdeploy/travis-456/linuxdeploy-i386.AppImage
# also download Qt plugin, which is needed for the Qt UI
wget -N https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-i386.AppImage

wget -N https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage

wget -N https://github.com/AppImage/AppImageKit/releases/download/continuous/runtime-armhf

chmod +x linuxdeploy*-i386.AppImage
chmod +x appimagetool*.AppImage

export ARCH=arm

# git clone https://github.com/NixOS/patchelf.git
# cd patchelf
# ./bootstrap.sh
# ./configure
# make -j2
# cd ..

mkdir linuxdeploy
cd linuxdeploy
../linuxdeploy-i386.AppImage --appimage-extract
# fix arm
rm -rf squashfs-root/usr/bin/strip squashfs-root/usr/bin/patchelf
# ln -s ../../../../patchelf/src/patchelf squashfs-root/usr/bin/patchelf
# cp ../patchelf/src/patchelf squashfs-root/usr/bin/
# cp ../patchelf squashfs-root/usr/bin/
echo '#!/bin/bash' > squashfs-root/usr/bin/patchelf
# echo 'echo patchelf $@>>/home/christopher/linux-packaging-scripts/patchelf.log' >> squashfs-root/usr/bin/patchelf
chmod +x squashfs-root/usr/bin/patchelf
# ln -s /usr/arm-linux-gnueabihf/bin/strip squashfs-root/usr/bin/strip
# cp /usr/arm-linux-gnueabihf/bin/strip squashfs-root/usr/bin/strip
echo '#!/bin/bash' > squashfs-root/usr/bin/strip
chmod +x squashfs-root/usr/bin/strip
cd ..
mkdir linuxdeploy-plugin-qt
cd linuxdeploy-plugin-qt
../linuxdeploy-plugin-qt-i386.AppImage --appimage-extract
# fix arm
rm -rf squashfs-root/usr/bin/strip squashfs-root/usr/bin/patchelf
# ln -s ../../../../patchelf/src/patchelf squashfs-root/usr/bin/patchelf
# cp ../patchelf/src/patchelf squashfs-root/usr/bin/
# cp ../patchelf squashfs-root/usr/bin/
echo '#!/bin/bash' > squashfs-root/usr/bin/patchelf
# echo 'echo patchelf $@>>/home/christopher/linux-packaging-scripts/patchelf.log' >> squashfs-root/usr/bin/patchelf
chmod +x squashfs-root/usr/bin/patchelf
# ln -s /usr/arm-linux-gnueabihf/bin/strip squashfs-root/usr/bin/strip
# cp /usr/arm-linux-gnueabihf/bin/strip squashfs-root/usr/bin/strip
echo '#!/bin/bash' > squashfs-root/usr/bin/strip
chmod +x squashfs-root/usr/bin/strip
cd ..
mkdir appimagetool
cd appimagetool
../appimagetool-x86_64.AppImage --appimage-extract
cd ..
LINUXDEPLOY_BIN=linuxdeploy/squashfs-root/AppRun
LINUXDEPLOY_PLUGIN_QT_BIN=linuxdeploy-plugin-qt/squashfs-root/AppRun
APPIMAGETOOL_BIN=appimagetool/squashfs-root/AppRun

check_run $LINUXDEPLOY_BIN --appdir $APP_DIR -i $BUILD_DIR/mcpelauncher-ui-qt.png -d $BUILD_DIR/mcpelauncher-ui-qt.desktop

export QML_SOURCES_PATHS=$SOURCE_DIR/mcpelauncher-ui/mcpelauncher-ui-qt/qml/:$SOURCE_DIR/mcpelauncher/mcpelauncher-webview
check_run $LINUXDEPLOY_PLUGIN_QT_BIN --appdir $APP_DIR

cp -r /usr/lib/arm-linux-gnueabihf/nss $APP_DIR/usr/lib/
curl  https://curl.haxx.se/ca/cacert.pem --output $APP_DIR/usr/share/mcpelauncher/cacert.pem
rm $APP_DIR/AppRun
cp ./AppRun $APP_DIR/AppRun
chmod +x $APP_DIR/AppRun

export OUTPUT="Minecraft_Bedrock_Launcher-${ARCH}.0.0.${BUILD_NUM}.AppImage"
export ARCH=arm
check_run $APPIMAGETOOL_BIN --comp xz ${UPDATE_INFORMATION+"-u"} ${UPDATE_INFORMATION} --runtime-file runtime-armhf $APP_DIR $OUTPUT
mv Minecraft*.AppImage output
mv *.zsync output/version.${ARCH}.zsync

cleanup_build
