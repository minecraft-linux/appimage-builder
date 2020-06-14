quirk_build_msa() {
  add_cmake_options -DCMAKE_CXX_FLAGS="-DNDEBUG -I ${PWD}/curlappimageca"
}
quirk_build_mcpelauncher() {
  add_cmake_options -DZLIB_LIBRARY=/usr/lib/x86_64-linux-gnu/libz.so -DPNG_LIBRARY=/usr/lib/x86_64-linux-gnu/libpng.so -DPNG_PNG_INCLUDE_DIR=/usr/include/libpng -DX11_X11_LIB=/usr/lib/x86_64-linux-gnu/libX11.so -DCURL_LIBRARY=/usr/lib/x86_64-linux-gnu/libcurl.so -DUDEV_LIBRARY=/lib/x86_64-linux-gnu/libudev.so -DCMAKE_CXX_FLAGS="-DNDEBUG -stdlib=libc++ -I ${PWD}/curlappimageca" -DBUILD_FAKE_JNI_TESTS=OFF -DBUILD_FAKE_JNI_EXAMPLES=OFF
}
quirk_build_mcpelauncher32() {
  add_cmake_options -DZLIB_LIBRARY=/usr/lib/i386-linux-gnu/libz.so -DPNG_LIBRARY=/usr/lib/i386-linux-gnu/libpng.so -DPNG_PNG_INCLUDE_DIR=/usr/include/libpng -DX11_X11_LIB=/usr/lib/i386-linux-gnu/libX11.so -DCURL_LIBRARY=/usr/lib/i386-linux-gnu/libcurl.so -DCMAKE_ASM_FLAGS=-m32 -DCMAKE_C_FLAGS=-m32 -DCMAKE_CXX_FLAGS="-m32 -DNDEBUG -stdlib=libc++ -I ${PWD}/curlappimageca" -DCMAKE_CXX_COMPILER_TARGET="i686-linux-gnu" -DBUILD_FAKE_JNI_TESTS=OFF -DBUILD_FAKE_JNI_EXAMPLES=OFF
}
quirk_build_mcpelauncher_ui() {
  add_cmake_options -DCMAKE_CXX_FLAGS="-DNDEBUG -I ${PWD}/curlappimageca -DDISABLE_64BIT=1"
}