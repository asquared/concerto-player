#!/bin/bash

# Build emergency audio plugin

mkdir -p staging_dir temp
cp -a files/* staging_dir/

# FIXME: this is an inefficient way of doing this
../scripts/stage-packages.pl alsa-tools alsa-utils mpg123

mksquashfs staging_dir emerg-audio.plugin -all-root -noappend
