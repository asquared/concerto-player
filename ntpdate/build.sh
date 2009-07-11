#!/bin/bash

# Build NTP plugin

mkdir -p staging_dir temp
cp -a files/* staging_dir/

../scripts/stage-packages.pl ntpdate

mksquashfs staging_dir ntpdate.plugin -all-root -noappend
