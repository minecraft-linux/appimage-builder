quirk_build_msa() {
  add_cmake_options "-DCURL_LIBRARY=/usr/lib/${DEBIANTARGET}/libcurl.so"
}
quirk_build_mcpelauncher() {
}
quirk_build_mcpelauncher_ui() {
  add_cmake_options "-DCURL_LIBRARY=/usr/lib/${DEBIANTARGET}/libcurl.so"
}

