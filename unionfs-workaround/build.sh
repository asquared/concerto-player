#!/bin/bash

# Concerto configurator scripts

mkdir -p staging_dir temp
cp -a files/* staging_dir/

mksquashfs staging_dir unionfs-workaround.plugin -all-root -noappend
