#!/bin/bash

# Concerto configurator scripts

mkdir -p staging_dir temp
cp -a files/* staging_dir/

../scripts/stage-packages.pl libsdl1.2debian libsdl-ttf2.0-0

mksquashfs staging_dir splash-server.plugin -all-root -noappend
