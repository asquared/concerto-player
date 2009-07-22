#!/bin/bash

# Concerto configurator scripts

mkdir -p staging_dir temp
cp -a files/* staging_dir/

../scripts/stage-packages.pl libwww-perl

mksquashfs staging_dir concerto-scripts.plugin -all-root -noappend
