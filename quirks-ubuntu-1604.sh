git clone https://github.com/openssl/openssl.git -b openssl-3.2
pushd openssl
setarch i386 ./config -m32 --prefix=$PWD/../copenssl32 --openssldir=$PWD/../copenssl32/ssl
make install_sw
./config --prefix=$PWD/../copenssl64 --openssldir=$PWD/../copenssl64/ssl
make clean
make install_sw
export LD_LIBRARY_PATH=$PWD/../copenssl64/lib:$PWD/../copenssl32/lib:${LD_LIBRARY_PATH}
popd
MCPELAUNCHER_CFLAGS32="-I ${PWD}/copenssl32/include -Wl,-L$PWD/copenssl32/lib $MCPELAUNCHER_CFLAGS32"
MCPELAUNCHER_CFLAGS="-stdlib=libc++ -I ${PWD}/copenssl64/include -Wl,-L$PWD/copenssl64/lib $MCPELAUNCHER_CFLAGS"
MCPELAUNCHER_CXXFLAGS32="-stdlib=libc++ $MCPELAUNCHER_CXXFLAGS32"
MCPELAUNCHER_CXXFLAGS="-stdlib=libc++ $MCPELAUNCHER_CXXFLAGS"
MCPELAUNCHERUI_CFLAGS="-I ${PWD}/copenssl64/include -Wl,-L$PWD/copenssl64/lib $MCPELAUNCHERUI_CFLAGS"

quirk_build_msa() {
  add_cmake_options -DQT_RPATH=/opt/qt59/lib/
}
quirk_build_mcpelauncher() {
  DEBIAN_FRONTEND=noninteractive apt -y remove libegl1-mesa-dev:i386 libevdev-dev:i386 libpng-dev:i386 libx11-dev:i386 libxcursor-dev:i386 libxinerama-dev:i386 libxi-dev:i386 libxrandr-dev:i386 libcurl4-openssl-dev:i386 libudev-dev:i386 libevdev-dev:i386 libegl1-mesa-dev:i386 zlib1g-dev:i386
  DEBIAN_FRONTEND=noninteractive apt -y install libegl1-mesa-dev libevdev-dev libpng-dev libx11-dev libxcursor-dev libxinerama-dev libxi-dev libxrandr-dev libcurl4-openssl-dev libudev-dev libevdev-dev libegl1-mesa-dev libasound2 zlib1g-dev
  add_cmake_options -DZLIB_LIBRARY=/usr/lib/x86_64-linux-gnu/libz.so -DPNG_LIBRARY=/usr/lib/x86_64-linux-gnu/libpng.so -DPNG_PNG_INCLUDE_DIR=/usr/include/libpng -DX11_X11_LIB=/usr/lib/x86_64-linux-gnu/libX11.so -DCURL_LIBRARY=/usr/lib/x86_64-linux-gnu/libcurl.so "-DOPENSSL_SSL_LIBRARY=$PWD/copenssl64/lib64/libssl.so" "-DOPENSSL_CRYPTO_LIBRARY=$PWD/copenssl64/lib64/libcrypto.so" "-DOPENSSL_INCLUDE_DIR=$PWD/copenssl64/include"
}
quirk_build_mcpelauncher32() {
  add_cmake_options -DCMAKE_CXX_COMPILER_TARGET="i686-linux-gnu" -DBUILD_FAKE_JNI_TESTS=OFF -DBUILD_FAKE_JNI_EXAMPLES=OFF -DUSE_OWN_CURL=ON -DOPENSSL_ROOT_DIR=$PWD/copenssl32/ -DOPENSSL_LIBRARIES=$PWD/copenssl32/lib
}
quirk_build_mcpelauncher_ui() {
  add_cmake_options -DCMAKE_INSTALL_RPATH="/opt/qt59/lib/:${APP_DIR}/usr/lib/" "-DOPENSSL_SSL_LIBRARY=$PWD/copenssl64/lib64/libssl.so" "-DOPENSSL_CRYPTO_LIBRARY=$PWD/copenssl64/lib64/libcrypto.so" "-DOPENSSL_INCLUDE_DIR=$PWD/copenssl64/include"
}

