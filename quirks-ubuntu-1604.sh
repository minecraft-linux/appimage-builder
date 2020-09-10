git clone https://github.com/openssl/openssl.git -b OpenSSL_1_1_1-stable
pushd openssl
setarch i386 ./config -m32 --prefix=$PWD/../copenssl32 --openssldir=$PWD/../copenssl32/ssl
make install_sw
./config --prefix=$PWD/../copenssl64 --openssldir=$PWD/../copenssl64/ssl
make clean
make install_sw
export LD_LIBRARY_PATH=$PWD/../copenssl64/lib:$PWD/../copenssl32/lib:${LD_LIBRARY_PATH}
popd
quirk_build_msa() {
  add_cmake_options -DQT_RPATH=/opt/qt59/lib/ -DCMAKE_C_COMPILER="/usr/bin/gcc" -DCMAKE_CXX_COMPILER="/usr/bin/g++" -DCMAKE_CXX_FLAGS="-DNDEBUG -I ${PWD}/curlappimageca"
}
quirk_build_mcpelauncher() {
  DEBIAN_FRONTEND=noninteractive apt -y install libegl1-mesa-dev libevdev-dev libpng-dev libx11-dev libxi-dev libcurl4-openssl-dev libudev-dev libevdev-dev libegl1-mesa-dev libasound2 zlib1g-dev
  add_cmake_options -DZLIB_LIBRARY=/usr/lib/x86_64-linux-gnu/libz.so -DPNG_LIBRARY=/usr/lib/x86_64-linux-gnu/libpng.so -DPNG_PNG_INCLUDE_DIR=/usr/include/libpng -DX11_X11_LIB=/usr/lib/x86_64-linux-gnu/libX11.so -DCURL_LIBRARY=/usr/lib/x86_64-linux-gnu/libcurl.so -DCMAKE_CXX_FLAGS="-DNDEBUG -stdlib=libc++ -I ${PWD}/curlappimageca -I ${PWD}/copenssl64/include -Wl,-L$PWD/copenssl64/lib" -DBUILD_FAKE_JNI_TESTS=OFF -DBUILD_FAKE_JNI_EXAMPLES=OFF -DOPENSSL_ROOT_DIR=$PWD/copenssl64/  -DOPENSSL_LIBRARIES=$PWD/copenssl64/lib
}
quirk_build_mcpelauncher32() {
  add_cmake_options -DCMAKE_ASM_FLAGS=-m32 -DCMAKE_C_FLAGS=-m32 -DCMAKE_CXX_FLAGS="-m32 -DNDEBUG -stdlib=libc++ -I ${PWD}/curlappimageca -I ${PWD}/copenssl32/include -Wl,-L$PWD/copenssl32/lib" -DCMAKE_CXX_COMPILER_TARGET="i686-linux-gnu" -DBUILD_FAKE_JNI_TESTS=OFF -DBUILD_FAKE_JNI_EXAMPLES=OFF -DUSE_OWN_CURL=ON -DOPENSSL_ROOT_DIR=$PWD/copenssl32/ -DOPENSSL_LIBRARIES=$PWD/copenssl32/lib
}
quirk_build_mcpelauncher_ui() {
  add_cmake_options -DCMAKE_INSTALL_RPATH="/opt/qt59/lib/:${APP_DIR}/usr/lib/" -DCMAKE_CXX_FLAGS="-DNDEBUG -I ${PWD}/curlappimageca -DLAUNCHER_CHANGE_LOG=\"\\\"Changes from flatpak-0.0.4><ul>    <li>Added Changelog</li>    <li>Fixed saving gamedata in Internal Storage. Please revert the previous workaround with 'flatpak --user --reset io.mrarm.mcpelauncher' or 'sudo flatpak --reset io.mrarm.mcpelauncher', then move the created '~/data/data/' folder to '~/.var/app/io.mrarm.mcpelauncher/data/mcpelauncher'</li>    <li>Minecraft 1.16.100.54 now working</li>    <li>Added Reset the Launcher via Settings</li>    <li>Added About Page with Version information</li>    <li>Added Compatibility report with more detailed Unsupported message</li>    <li>Extended the Troubleshooter to include more Items like the Compatibility Report</li>    <li>Moved again from fake-jni to libjnivm as fake java native interface</li>    <li>Also run 1.16.20 - 1.16.100 x86 variants</li>    <li>Block Google Play latest if it would be incompatible incl. Troubleshooter entry</li>    <li>Fix Google Play latest still hidden after login to the launcher</li>    <li>Improve integrated UpdateChecker to respond if you click on Check for Updates</li>    <li>Show error if update failed, instead of failing silently</li></ul>\\\"\""
}

