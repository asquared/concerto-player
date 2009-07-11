#!/usr/bin/env perl

use strict;
use warnings;

# calculate a package's dependencies that aren't already in the base system

my $pkg = $ARGV[0];

my $output = `apt-get --recon install $pkg`;

while ($output =~ /^Inst (\w+)/gm) {
    print "$1\n";
}
