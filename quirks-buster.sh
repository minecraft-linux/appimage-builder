quirk_build_msa() {
  add_cmake_options -DDEB_OS_NAME=ubuntu-bionic
}
quirk_build_mcpelauncher() {
  add_cmake_options -DUSE_OWN_CURL=ON -DOPENSSL_ROOT_DIR=/usr/lib/i386-linux-gnu/ -DDEB_OS_NAME=ubuntu-bionic
}
quirk_build_mcpelauncher_ui() {
  add_cmake_options -DCPACK_DEBIAN_PACKAGE_DEPENDS="libc6 (>=2.14), libssl1.1, libuv1, libzip4, libqt5widgets5, libqt5webenginewidgets5, libqt5quick5, libqt5svg5, libqt5quickcontrols2-5, libqt5quicktemplates2-5, libqt5concurrent5, libprotobuf17, qml-module-qtquick2, qml-module-qtquick-layouts, qml-module-qtquick-controls, qml-module-qtquick-controls2, qml-module-qtquick-window2, qml-module-qtquick-dialogs, qml-module-qt-labs-settings, qml-module-qt-labs-folderlistmodel"
}

