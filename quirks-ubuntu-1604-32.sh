git clone https://github.com/openssl/openssl.git -b OpenSSL_1_1_1-stable
pushd openssl
setarch i386 ./config -m32 --prefix=$PWD/../copenssl32 --openssldir=$PWD/../copenssl32/ssl
make install_sw -j8
export LD_LIBRARY_PATH=$PWD/../copenssl32/lib:${LD_LIBRARY_PATH}
popd
MCPELAUNCHER_CFLAGS="-I ${PWD}/copenssl32/include -Wl,-L$PWD/copenssl32/lib $MCPELAUNCHER_CFLAGS"
MCPELAUNCHER_CXXFLAGS="-stdlib=libc++ $MCPELAUNCHER_CXXFLAGS"

quirk_build_msa() {
  add_cmake_options -DQT_RPATH=/opt/qt59/lib/ -DOPENSSL_ROOT_DIR=$PWD/copenssl32/ -DCMAKE_FIND_ROOT_PATH=/usr/lib/i386-linux-gnu/ -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=BOTH -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH
}
quirk_build_mcpelauncher() {
  add_cmake_options -DCMAKE_CXX_COMPILER_TARGET="i686-linux-gnu" -DBUILD_FAKE_JNI_TESTS=OFF -DBUILD_FAKE_JNI_EXAMPLES=OFF -DUSE_OWN_CURL=ON -DOPENSSL_ROOT_DIR=$PWD/copenssl32/ -DOPENSSL_LIBRARIES=$PWD/copenssl32/lib -DJNI_USE_JNIVM=ON -DXAL_WEBVIEW_QT_PATH=.
}
quirk_build_mcpelauncher_ui() {
  add_cmake_options -DCMAKE_INSTALL_RPATH="/opt/qt59/lib/:${APP_DIR}/usr/lib/" -DOPENSSL_ROOT_DIR=$PWD/copenssl32/ -DCMAKE_FIND_ROOT_PATH=/usr/lib/i386-linux-gnu/ -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=BOTH -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH
}