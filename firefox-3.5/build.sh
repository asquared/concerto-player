#!/bin/bash

# Build the base system.
# Requires: debootstrap

. ./config
mkdir temp

if [ ! -r temp/release.tar.bz2 ]; then
    ( cd temp; wget -O release.tar.bz2 $RELEASE_URL )
fi

mkdir -p staging_dir/opt

tar -jxvf temp/release.tar.bz2 -C staging_dir/opt
tar -xvf fullfullscreen.tar -C staging_dir/opt/firefox/extensions
patch -p2 < firefox_config_patches

mksquashfs staging_dir firefox.plugin -all-root
