quirk_build_msa() {
  add_cmake_options -DQT_RPATH=/opt/qt59/lib/ -DCMAKE_C_COMPILER="/usr/bin/gcc" -DCMAKE_CXX_COMPILER="/usr/bin/g++"
}
quirk_build_mcpelauncher() {
  add_cmake_options -DZLIB_LIBRARY=/usr/lib/x86_64-linux-gnu/libz.so -DPNG_LIBRARY=/usr/lib/x86_64-linux-gnu/libpng.so -DPNG_PNG_INCLUDE_DIR=/usr/include/libpng -DX11_X11_LIB=/usr/lib/x86_64-linux-gnu/libX11.so -DCURL_LIBRARY=/usr/lib/x86_64-linux-gnu/libcurl.so "-DCMAKE_C_FLAGS=-include ${SOURCE_DIR}/../compat.h" "-DCMAKE_CXX_FLAGS=-include ${SOURCE_DIR}/../compat.h -stdlib=libc++"
}
quirk_build_mcpelauncher_ui() {
  add_cmake_options -DCMAKE_INSTALL_RPATH=/opt/qt59/lib/
}

