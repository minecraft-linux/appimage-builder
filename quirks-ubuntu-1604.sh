quirk_build_msa() {
  add_cmake_options -DQT_RPATH=/opt/qt59/lib/
}
quirk_build_mcpelauncher() {

}
quirk_build_mcpelauncher_ui() {
  add_cmake_options -DCMAKE_INSTALL_RPATH=/opt/qt59/lib/
}

