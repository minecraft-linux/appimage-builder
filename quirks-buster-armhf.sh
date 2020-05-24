

quirk_build_msa() {
  add_cmake_options -DCMAKE_TOOLCHAIN_FILE=${PWD}/armhftoolchain.txt -DCPACK_DEBIAN_PACKAGE_ARCHITECTURE=armhf
}
quirk_build_mcpelauncher() {
  add_cmake_options -DCMAKE_TOOLCHAIN_FILE=${PWD}/armhftoolchain.txt -DCPACK_DEBIAN_PACKAGE_ARCHITECTURE=armhf
}
quirk_build_mcpelauncher32() {
  add_cmake_options -DCMAKE_TOOLCHAIN_FILE=${PWD}/armhftoolchain.txt -DCPACK_DEBIAN_PACKAGE_ARCHITECTURE=armhf
}
quirk_build_mcpelauncher_ui() {
  add_cmake_options -DCMAKE_TOOLCHAIN_FILE=${PWD}/armhftoolchain.txt -DCPACK_DEBIAN_PACKAGE_ARCHITECTURE=armhf -DQt5QuickCompiler_FOUND:BOOL=OFF
}
