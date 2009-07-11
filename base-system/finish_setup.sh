#!/bin/bash

export LC_ALL=C
mount -t proc proc /proc
apt-get -y update
apt-get -y upgrade
# basic system tools
apt-get -y install alsa-tools alsa-utils ethtool lm-sensors mpg123 openssh-server wireless-tools wpasupplicant xserver-xorg xbase-clients tightvncserver wget vim
# stuff to make firefox work right
apt-get -y install libgtk2.0-0 xfwm4
apt-get -y clean
umount /proc
# rm -rf files_we_dont_need
