#!/bin/bash

# Build the base system.
# Requires: debootstrap

. ./config

if [ "`whoami`" != "root" ]; then
    export ORIG_USER="`whoami`"
    echo "Sudo-ing ourselves..."
    exec sudo $0 $@
fi

echo "Hooray, we're root!"

if [ ! -r $RELEASE.cache.tar ]; then
    echo "We need to build a cache. Please stand by..."
    ./cache.sh
fi

#debootstrap --foreign --arch=i386 --unpack-tarball=`pwd`/$RELEASE.cache.tar $RELEASE staging_dir/
debootstrap --foreign --arch=i386 $RELEASE staging_dir

# cocaine for x86_64 build host machines
if [ "`uname -m`" == "x86_64" ]; then
    LINUX32=linux32
else
    LINUX32=
fi

$LINUX32 chroot staging_dir /debootstrap/debootstrap --second-stage
# copy any extra files we might have
cp -R files_to_copy/* staging_dir/
cp finish_setup.sh staging_dir/
$LINUX32 chroot staging_dir /finish_setup.sh
rm staging_dir/finish_setup.sh

mksquashfs staging_dir concerto.squashfs -all-root -noappend
chown "$ORIG_USER" concerto.squashfs
