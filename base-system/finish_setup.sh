#!/bin/bash

export LC_ALL=C
mount -t proc proc /proc
apt-get -y update
apt-get -y upgrade
apt-get -y install alsa-tools alsa-utils ethtool lm-sensors mpg123 openssh-server wireless-tools wpasupplicant xserver-xorg xbase-clients tightvncserver wget vim
umount /proc
# rm -rf files_we_dont_need
