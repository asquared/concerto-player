#!/bin/bash

# Build emergency audio plugin

mkdir -p staging_dir temp
cp -a files/* staging_dir/

../scripts/stage-packages.pl alsa-tools alsa-utils mpg123
../scripts/stage-packages.pl libwww-perl libcrypt-openssl-rsa-perl

mksquashfs staging_dir emerg-audio.plugin -all-root -noappend
