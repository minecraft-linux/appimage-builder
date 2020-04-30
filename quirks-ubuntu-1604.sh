quirk_build_msa() {
  add_cmake_options -DQT_RPATH=/opt/qt59/lib/ -DCMAKE_C_COMPILER="/usr/bin/gcc" -DCMAKE_CXX_COMPILER="/usr/bin/g++" -DCMAKE_CXX_FLAGS="-DNDEBUG -I ${PWD}/curlappimageca"
}
quirk_build_mcpelauncher() {
  DEBIAN_FRONTEND=noninteractive apt -y install libegl1-mesa-dev libevdev-dev libpng-dev libx11-dev libxi-dev libcurl4-openssl-dev libudev-dev libevdev-dev libegl1-mesa-dev libasound2 zlib1g-dev
  add_cmake_options -DZLIB_LIBRARY=/usr/lib/x86_64-linux-gnu/libz.so -DPNG_LIBRARY=/usr/lib/x86_64-linux-gnu/libpng.so -DPNG_PNG_INCLUDE_DIR=/usr/include/libpng -DX11_X11_LIB=/usr/lib/x86_64-linux-gnu/libX11.so -DCURL_LIBRARY=/usr/lib/x86_64-linux-gnu/libcurl.so -DCMAKE_CXX_FLAGS="-DNDEBUG -stdlib=libc++ -I ${PWD}/curlappimageca" -DBUILD_FAKE_JNI_TESTS=OFF -DBUILD_FAKE_JNI_EXAMPLES=OFF
}
quirk_build_mcpelauncher32() {
  add_cmake_options -DCMAKE_ASM_FLAGS=-m32 -DCMAKE_C_FLAGS=-m32 -DCMAKE_CXX_FLAGS="-m32 -DNDEBUG -stdlib=libc++ -I ${PWD}/curlappimageca" -DCMAKE_CXX_COMPILER_TARGET="i686-linux-gnu" -DBUILD_FAKE_JNI_TESTS=OFF -DBUILD_FAKE_JNI_EXAMPLES=OFF -DUSE_OWN_CURL=ON -DOPENSSL_ROOT_DIR=/usr/lib/i386-linux-gnu/
}
quirk_build_mcpelauncher_ui() {
  add_cmake_options -DCMAKE_INSTALL_RPATH=/opt/qt59/lib/ -DCMAKE_CXX_FLAGS="-DNDEBUG -I ${PWD}/curlappimageca"
}

