git clone https://github.com/openssl/openssl.git -b OpenSSL_1_1_1-stable
pushd openssl
setarch i386 ./config -m32 --prefix=$PWD/../copenssl32 --openssldir=$PWD/../copenssl32/ssl
make install_sw -j8
./config --prefix=$PWD/../copenssl64 --openssldir=$PWD/../copenssl64/ssl
make clean -j8
make install_sw -j8
export LD_LIBRARY_PATH=$PWD/../copenssl64/lib:$PWD/../copenssl32/lib:${LD_LIBRARY_PATH}
popd
MCPELAUNCHER_CFLAGS32="-I ${PWD}/copenssl32/include -Wl,-L$PWD/copenssl32/lib $MCPELAUNCHER_CFLAGS32"
MCPELAUNCHER_CFLAGS="-stdlib=libc++ -I ${PWD}/copenssl64/include -Wl,-L$PWD/copenssl64/lib $MCPELAUNCHER_CFLAGS"
MCPELAUNCHER_CXXFLAGS32="-stdlib=libc++ $MCPELAUNCHER_CXXFLAGS32"
MCPELAUNCHER_CXXFLAGS="-stdlib=libc++ $MCPELAUNCHER_CXXFLAGS"
MCPELAUNCHER_QUIRKROOT="$PWD"

quirk_build_msa() {
  add_cmake_options -DQT_RPATH=/opt/qt59/lib/
}
quirk_build_mcpelauncher() {
  DEBIAN_FRONTEND=noninteractive apt -y remove libegl1-mesa-dev:i386 libevdev-dev:i386 libpng-dev:i386 libx11-dev:i386 libxi-dev:i386 libcurl4-openssl-dev:i386 libudev-dev:i386 libevdev-dev:i386 libegl1-mesa-dev:i386 zlib1g-dev:i386
  DEBIAN_FRONTEND=noninteractive apt -y install libegl1-mesa-dev libevdev-dev libpng-dev libx11-dev libxi-dev libcurl4-openssl-dev libudev-dev libevdev-dev libegl1-mesa-dev libasound2 zlib1g-dev
  add_cmake_options -DZLIB_LIBRARY=/usr/lib/x86_64-linux-gnu/libz.so -DPNG_LIBRARY=/usr/lib/x86_64-linux-gnu/libpng.so -DPNG_PNG_INCLUDE_DIR=/usr/include/libpng -DX11_X11_LIB=/usr/lib/x86_64-linux-gnu/libX11.so -DCURL_LIBRARY=/usr/lib/x86_64-linux-gnu/libcurl.so -DBUILD_FAKE_JNI_TESTS=OFF -DBUILD_FAKE_JNI_EXAMPLES=OFF -DOPENSSL_ROOT_DIR=$MCPELAUNCHER_QUIRKROOT/copenssl64/ -DOPENSSL_SSL_LIBRARY=$MCPELAUNCHER_QUIRKROOT/copenssl64/lib/libssl.so  -DOPENSSL_CRYPTO_LIBRARY=$MCPELAUNCHER_QUIRKROOT/copenssl64/lib/libcrypto.so -DJNI_USE_JNIVM=ON -DXAL_WEBVIEW_QT_PATH=.
}
quirk_build_mcpelauncher32() {
  add_cmake_options -DCMAKE_CXX_COMPILER_TARGET="i686-linux-gnu" -DBUILD_FAKE_JNI_TESTS=OFF -DBUILD_FAKE_JNI_EXAMPLES=OFF -DUSE_OWN_CURL=ON  -DOPENSSL_ROOT_DIR=$MCPELAUNCHER_QUIRKROOT/copenssl32/ -DOPENSSL_SSL_LIBRARY=$MCPELAUNCHER_QUIRKROOT/copenssl32/lib/libssl.so  -DOPENSSL_CRYPTO_LIBRARY=$MCPELAUNCHER_QUIRKROOT/copenssl32/lib/libcrypto.so -DBUILD_WEBVIEW=OFF -DJNI_USE_JNIVM=ON -DXAL_WEBVIEW_QT_PATH=.
}
quirk_build_mcpelauncher_ui() {
  add_cmake_options -DCMAKE_INSTALL_RPATH="/opt/qt59/lib/:${APP_DIR}/usr/lib/"
}

