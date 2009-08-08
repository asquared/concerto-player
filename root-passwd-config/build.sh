#!/bin/bash

mkdir -p staging_dir temp
cp -a files/* staging_dir/

mksquashfs staging_dir root-passwd-config.plugin -all-root -noappend
