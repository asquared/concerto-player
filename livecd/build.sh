#!/bin/bash

mkdir -p staging_dir/

# you need to put a kernel in files/kernel 
# (and its module plugin in files/modules-x.y.zz.plugin) 
# and isolinux in files/isolinux to make this happy

# copy the external files
cp -a files/* staging_dir/

# copy the main system .squashfs file
cp ../base-system/concerto.squashfs staging_dir/

# copy plugins
for plugin in \
    blank-cursor-theme concerto-scripts \
    firefox-3.5 ntpdate unionfs-workaround root-shell \
    splash-server wireless-config root-passwd-config
do
    cp ../$plugin/*.plugin staging_dir/
done

# copy initrd
cp ../initrd/initrd staging_dir/

# and make the ISO...
mkisofs -o concerto.iso -b isolinux/isolinux.bin -c isolinux/boot.cat \
    -no-emul-boot -boot-load-size 4 -boot-info-table -r -J staging_dir/
