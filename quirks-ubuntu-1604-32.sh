git clone https://github.com/openssl/openssl.git -b OpenSSL_1_1_1-stable
pushd openssl
setarch i386 ./config -m32 --prefix=$PWD/../copenssl32 --openssldir=$PWD/../copenssl32/ssl
make install_sw
export LD_LIBRARY_PATH=$PWD/../copenssl32/lib:${LD_LIBRARY_PATH}
popd
quirk_build_msa() {
  add_cmake_options -DQT_RPATH=/opt/qt59/lib/ -DCMAKE_C_FLAGS=-m32 -DCMAKE_CXX_FLAGS="-m32 -DNDEBUG -I ${PWD}/curlappimageca" -DOPENSSL_ROOT_DIR=/usr/lib/i386-linux-gnu/ -DCMAKE_FIND_ROOT_PATH=/usr/lib/i386-linux-gnu/ -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=BOTH -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH
}
quirk_build_mcpelauncher() {
  add_cmake_options -DCMAKE_ASM_FLAGS=-m32 -DCMAKE_C_FLAGS=-m32 -DCMAKE_CXX_FLAGS="-m32 -DNDEBUG -stdlib=libc++ -I ${PWD}/curlappimageca -I ${PWD}/copenssl32/include -Wl,-L$PWD/copenssl32/lib" -DCMAKE_CXX_COMPILER_TARGET="i686-linux-gnu" -DBUILD_FAKE_JNI_TESTS=OFF -DBUILD_FAKE_JNI_EXAMPLES=OFF -DUSE_OWN_CURL=ON -DOPENSSL_ROOT_DIR=$PWD/copenssl32/ -DOPENSSL_LIBRARIES=$PWD/copenssl32/lib -DJNI_USE_JNIVM=ON -DXAL_WEBVIEW_QT_PATH=.
}
quirk_build_mcpelauncher_ui() {
  download_repo versionsdb https://github.com/minecraft-linux/mcpelauncher-versiondb.git $(cat versionsdb.txt)
  add_cmake_options -DCMAKE_INSTALL_RPATH="/opt/qt59/lib/:${APP_DIR}/usr/lib/" -DCMAKE_C_FLAGS=-m32 -DCMAKE_CXX_FLAGS="-m32 -DNDEBUG -I ${PWD}/curlappimageca" -DLAUNCHER_VERSION_NAME="$(cat version.txt).${BUILD_NUM}-AppImage-x86" -DLAUNCHER_VERSION_CODE=${BUILD_NUM} -DLAUNCHER_CHANGE_LOG="Launcher $(cat version.txt)<br/>$(cat changelog.txt)" -DOPENSSL_ROOT_DIR=/usr/lib/i386-linux-gnu/ -DCMAKE_FIND_ROOT_PATH=/usr/lib/i386-linux-gnu/ -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=BOTH -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH -DLAUNCHER_ENABLE_GOOGLE_PLAY_LICENCE_CHECK=ON -DLAUNCHER_DISABLE_DEV_MODE=OFF -DLAUNCHER_VERSIONDB_URL=https://raw.githubusercontent.com/minecraft-linux/mcpelauncher-versiondb/$(cat versionsdbremote.txt) -DLAUNCHER_VERSIONDB_PATH=$SOURCE_DIR/versionsdb
}

