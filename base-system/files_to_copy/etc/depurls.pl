#!/usr/bin/env perl

use strict;
use warnings;

# calculate a package's dependencies that aren't already in the base system

my $pkg_str = join ' ', @ARGV;
my $output = `apt-get install -qq --print-uris $pkg_str`;

while ($output =~ /^'([^']+)/gm) {
    print "$1\n";
}
