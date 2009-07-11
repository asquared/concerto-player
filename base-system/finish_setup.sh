#!/bin/bash

export LC_ALL=C
mount -t proc proc /proc
apt-get -y update
apt-get -y upgrade
# basic system tools
apt-get -y install ethtool lm-sensors openssh-server wireless-tools wpasupplicant xserver-xorg xbase-clients tightvncserver wget vim
apt-get -y clean
umount /proc
# rm -rf files_we_dont_need
