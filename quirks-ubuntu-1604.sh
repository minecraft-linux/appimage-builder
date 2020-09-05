git clone https://github.com/openssl/openssl.git -b OpenSSL_1_1_1-stable
cd openssl
setarch i386 ./config -m32 --prefix=$PWD/../copenssl32 --openssldir=$PWD/../copenssl32/ssl
make install
./config --prefix=$PWD/../copenssl64 --openssldir=$PWD/../copenssl64/ssl
make clean
make install
export LD_LIBRARY_PATH=$PWD/../copenssl64/lib:$PWD/../copenssl32/lib:${LD_LIBRARY_PATH}
cd ..
quirk_build_msa() {
  add_cmake_options -DQT_RPATH=/opt/qt59/lib/ -DCMAKE_C_COMPILER="/usr/bin/gcc" -DCMAKE_CXX_COMPILER="/usr/bin/g++" -DCMAKE_CXX_FLAGS="-DNDEBUG -I ${PWD}/curlappimageca"
}
quirk_build_mcpelauncher() {
  DEBIAN_FRONTEND=noninteractive apt -y install libegl1-mesa-dev libevdev-dev libpng-dev libx11-dev libxi-dev libcurl4-openssl-dev libudev-dev libevdev-dev libegl1-mesa-dev libasound2 zlib1g-dev
  add_cmake_options -DZLIB_LIBRARY=/usr/lib/x86_64-linux-gnu/libz.so -DPNG_LIBRARY=/usr/lib/x86_64-linux-gnu/libpng.so -DPNG_PNG_INCLUDE_DIR=/usr/include/libpng -DX11_X11_LIB=/usr/lib/x86_64-linux-gnu/libX11.so -DCURL_LIBRARY=/usr/lib/x86_64-linux-gnu/libcurl.so -DCMAKE_CXX_FLAGS="-DNDEBUG -stdlib=libc++ -I ${PWD}/curlappimageca -I ${PWD}/copenssl64/include -Wl,-L$PWD/copenssl64/lib" -DBUILD_FAKE_JNI_TESTS=OFF -DBUILD_FAKE_JNI_EXAMPLES=OFF -DOPENSSL_ROOT_DIR=$PWD/copenssl64/  -DOPENSSL_LIBRARIES=$PWD/copenssl64/lib
}
quirk_build_mcpelauncher32() {
  add_cmake_options -DCMAKE_ASM_FLAGS=-m32 -DCMAKE_C_FLAGS=-m32 -DCMAKE_CXX_FLAGS="-m32 -DNDEBUG -stdlib=libc++ -I ${PWD}/curlappimageca -I ${PWD}/copenssl32/include -Wl,-L$PWD/copenssl32/lib" -DCMAKE_CXX_COMPILER_TARGET="i686-linux-gnu" -DBUILD_FAKE_JNI_TESTS=OFF -DBUILD_FAKE_JNI_EXAMPLES=OFF -DUSE_OWN_CURL=ON -DOPENSSL_ROOT_DIR=$PWD/copenssl32/ -DOPENSSL_LIBRARIES=$PWD/copenssl32/lib
}
quirk_build_mcpelauncher_ui() {
  add_cmake_options -DCMAKE_INSTALL_RPATH="/opt/qt59/lib/:${APP_DIR}/usr/lib/" -DCMAKE_CXX_FLAGS="-DNDEBUG -I ${PWD}/curlappimageca"
}

