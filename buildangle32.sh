#!/bin/bash

git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH=$PATH:$PWD/depot_tools
git clone https://chromium.googlesource.com/angle/angle
pushd angle
python scripts/bootstrap.py
gclient sync
./build/install-build-deps.sh
gn gen out/Release --args='target_cpu="x86" is_debug=false angle_enable_swiftshader=false angle_enable_vulkan=false'
autoninja -C out/Release libEGL libGLESv2
popd