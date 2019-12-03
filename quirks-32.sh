quirk_build_msa() {
  add_cmake_options -DCMAKE_C_FLAGS=-m32 -DQt5_DIR=/usr/lib/i386-linux-gnu/cmake/Qt5 -DCMAKE_CXX_FLAGS=-m32
}
quirk_build_mcpelauncher() {
  add_cmake_options -DUSE_OWN_CURL=ON -DOPENSSL_ROOT_DIR=/usr/lib/i386-linux-gnu/
}
quirk_build_mcpelauncher_ui() {
  add_cmake_options -DUSE_OWN_CURL=ON -DOPENSSL_ROOT_DIR=/usr/lib/i386-linux-gnu/ -DCMAKE_C_FLAGS=-m32 -DCMAKE_CXX_FLAGS=-m32 -DQt5_DIR=/usr/lib/i386-linux-gnu/cmake/Qt5
}