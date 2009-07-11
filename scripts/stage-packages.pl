#!/usr/bin/env perl

use strict;
use warnings;

# run from a plugin directory, this will stage a debian package and all its 
# dependencies into staging_dir

my $pkg_list = join ' ', @ARGV;

my @urls = split /\n/, `sudo chroot ../base-system/staging_dir /etc/depurls.pl $pkg_list`;

for my $url (@urls) {
    if (system("wget -O temp/install.deb $url")) {
        die "failed to fetch package from $url?\n";
    }
    if (system("dpkg-deb -x temp/install.deb staging_dir")) {
        die "failed to extract package from $url?\n";
    }
}


