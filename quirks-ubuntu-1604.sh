quirk_build_msa() {
  add_cmake_options -DQT_RPATH=/opt/qt59/lib/
}
quirk_build_mcpelauncher() {
  add_cmake_options "-DCMAKE_C_FLAGS='-include ${PWD}/compat.h'" "-DCMAKE_CXX_FLAGS='-include ${PWD}/compat.h'"
}
quirk_build_mcpelauncher_ui() {
  add_cmake_options -DCMAKE_INSTALL_RPATH=/opt/qt59/lib/
}

