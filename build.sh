#!/bin/bash

source common.sh

QUIRKS_FILE=
OS_NAME=

while getopts "h?q:j:o:" opt; do
    case "$opt" in
    h|\?)
        echo "build.sh"
        echo "-j  Specify the number of jobs (the -j arg to make)"
        echo "-q  Specify the quirks file"
        echo "-o  Specify the OS name"
        exit 0
        ;;
    j)  MAKE_JOBS=$OPTARG
        ;;
    q)  QUIRKS_FILE=$OPTARG
        ;;
    o)  OS_NAME=$OPTARG
        ;;
    esac
done

load_quirks "$QUIRKS_FILE"

create_build_directories
call_quirk init

show_status "Downloading sources"
download_repo msa https://github.com/minecraft-linux/msa-manifest.git $(cat msa.commit)
download_repo mcpelauncher https://github.com/minecraft-linux/mcpelauncher-manifest.git $(cat mcpelauncher.commit)
download_repo mcpelauncher-ui https://github.com/minecraft-linux/mcpelauncher-ui-manifest.git $(cat mcpelauncher-ui.commit)

call_quirk build_start

reset_cmake_options
add_cmake_options -DENABLE_MSA_QT_UI=ON -DMSA_UI_PATH_DEV=OFF
add_cmake_options -DDEB_OS_NAME=$OS_NAME
call_quirk build_msa
build_component msa
install_component_cpack msa
reset_cmake_options
add_cmake_options -DDEB_OS_NAME=$OS_NAME
call_quirk build_mcpelauncher
build_component mcpelauncher
install_component_cpack mcpelauncher
reset_cmake_options
add_cmake_options -DDEB_OS_NAME=$OS_NAME
call_quirk build_mcpelauncher_ui

build_component mcpelauncher-ui
install_component_cpack mcpelauncher-ui

cleanup_build
