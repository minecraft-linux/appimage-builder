#!/bin/bash

source common.sh

QUIRKS_FILE=

while getopts "h?q:j:" opt; do
    case "$opt" in
    h|\?)
        echo "build.sh"
        echo "-j  Specify the number of jobs (the -j arg to make)"
        echo "-q  Specify the quirks file"
        exit 0
        ;;
    j)  MAKE_JOBS=$OPTARG
        ;;
    q)  QUIRKS_FILE=$OPTARG
        ;;
    esac
done

load_quirks "$QUIRKS_FILE"

create_build_directories
call_quirk init

show_status "Downloading sources"
download_repo msa https://github.com/minecraft-linux/msa-manifest.git
download_repo mcpelauncher https://github.com/minecraft-linux/mcpelauncher-manifest.git
download_repo mcpelauncher-ui https://github.com/minecraft-linux/mcpelauncher-ui-manifest.git

call_quirk build_start

reset_cmake_options
add_cmake_options -DENABLE_MSA_QT_UI=ON -DMSA_UI_PATH_DEV=OFF
call_quirk build_msa
build_component msa
reset_cmake_options
call_quirk build_mcpelauncher
build_component mcpelauncher
reset_cmake_options
call_quirk build_mcpelauncher_ui
build_component mcpelauncher-ui

cleanup_build
