quirk_build_msa() {
  add_cmake_options -DCMAKE_TOOLCHAIN_FILE=${PWD}/i386toolchain.txt
}
quirk_build_mcpelauncher() {
  add_cmake_options -DCMAKE_TOOLCHAIN_FILE=${PWD}/i386toolchain.txt
}
quirk_build_mcpelauncher32() {
  add_cmake_options -DCMAKE_TOOLCHAIN_FILE=${PWD}/i386toolchain.txt
}
quirk_build_mcpelauncher_ui() {
  add_cmake_options -DCMAKE_TOOLCHAIN_FILE=${PWD}/i386toolchain.txt
}

