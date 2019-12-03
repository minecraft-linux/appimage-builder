quirk_build_msa() {
  add_cmake_options -DCMAKE_C_FLAGS="-m32 -Wl,-latomic" -DCMAKE_CXX_FLAGS="-m32 -Wl,-latomic" -DQt5_DIR=/usr/lib/i386-linux-gnu/cmake/Qt5 -DOPENSSL_ROOT_DIR=/usr/lib/i386-linux-gnu/ -DCMAKE_FIND_ROOT_PATH=/usr/lib/i386-linux-gnu/
}
quirk_build_mcpelauncher() {
  add_cmake_options -DCMAKE_C_FLAGS="-Wl,-latomic" -DCMAKE_CXX_FLAGS="-Wl,-latomic" -DOPENSSL_ROOT_DIR=/usr/lib/i386-linux-gnu/ -DCMAKE_FIND_ROOT_PATH=/usr/lib/i386-linux-gnu/
}
quirk_build_mcpelauncher_ui() {
  add_cmake_options -DCMAKE_C_FLAGS="-m32 -Wl,-latomic" -DCMAKE_CXX_FLAGS="-m32 -Wl,-latomic" -DQt5_DIR=/usr/lib/i386-linux-gnu/cmake/Qt5 -DOPENSSL_ROOT_DIR=/usr/lib/i386-linux-gnu/ -DCMAKE_FIND_ROOT_PATH=/usr/lib/i386-linux-gnu/
}