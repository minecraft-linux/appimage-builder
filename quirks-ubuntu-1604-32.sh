quirk_build_msa() {
  add_cmake_options -DQT_RPATH=/opt/qt59/lib/ -DCMAKE_C_FLAGS=-m32 -DCMAKE_CXX_FLAGS=-m32 -DOPENSSL_ROOT_DIR=/usr/lib/i386-linux-gnu/ -DCMAKE_FIND_ROOT_PATH=/usr/lib/i386-linux-gnu/ -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=BOTH -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH
}
quirk_build_mcpelauncher() {
  add_cmake_options -DOPENSSL_ROOT_DIR=/usr/lib/i386-linux-gnu/ -DCMAKE_FIND_ROOT_PATH=/usr/lib/i386-linux-gnu/ -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=BOTH -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH
}
quirk_build_mcpelauncher_ui() {
  add_cmake_options -DCMAKE_INSTALL_RPATH="/opt/qt59/lib/:${APP_DIR}/usr/lib/" -DCMAKE_C_FLAGS=-m32 -DCMAKE_CXX_FLAGS=-m32 -DOPENSSL_ROOT_DIR=/usr/lib/i386-linux-gnu/ -DCMAKE_FIND_ROOT_PATH=/usr/lib/i386-linux-gnu/ -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=BOTH -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH
}

