quirk_build_msa() {
  add_cmake_options "-DCURL_LIBRARY=/usr/lib/${DEBIANTARGET}/libcurl.so" "-DQt6_DIR=/usr/lib/${DEBIANTARGET}/cmake/Qt6" "-DQt6GuiTools_DIR=/usr/lib/${DEBIANTARGET}/cmake/Qt6GuiTools"
}
quirk_build_mcpelauncher() {
  add_cmake_options "-DQt6_DIR=/usr/lib/${DEBIANTARGET}/cmake/Qt6" "-DQt6GuiTools_DIR=/usr/lib/${DEBIANTARGET}/cmake/Qt6GuiTools"
}
quirk_build_mcpelauncher_ui() {
  add_cmake_options "-DCURL_LIBRARY=/usr/lib/${DEBIANTARGET}/libcurl.so" "-DQt6_DIR=/usr/lib/${DEBIANTARGET}/cmake/Qt6" "-DQt6GuiTools_DIR=/usr/lib/${DEBIANTARGET}/cmake/Qt6GuiTools"
}

