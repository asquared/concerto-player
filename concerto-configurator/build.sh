#!/bin/bash

# Concerto configurator scripts

mkdir -p staging_dir temp
cp -a files/* staging_dir/

../scripts/stage-packages.pl libwww-perl libcrypt-openssl-rsa-perl

mksquashfs staging_dir concerto-configurator.plugin -all-root -noappend
