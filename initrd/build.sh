#!/bin/bash

# Build NTP plugin

mkdir -p staging_dir temp
cp -a files/* staging_dir/
( cd staging_dir/dev; sudo MAKEDEV std hda hdb hdc hdd console )

mksquashfs staging_dir initrd -all-root -noappend
