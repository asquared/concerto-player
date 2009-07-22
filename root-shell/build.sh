#!/bin/bash

# Concerto configurator scripts

mkdir -p staging_dir temp
cp -a files/* staging_dir/

mksquashfs staging_dir root-shell.plugin -all-root -noappend
