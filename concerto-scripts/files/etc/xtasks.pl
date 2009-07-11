#!/usr/bin/perl

use strict;
use warnings;

use Concerto::MACFinder qw/find_mac/;

# start X server and firefox

my $MAC = find_mac("eth0");

# disable X11 screensaver
system("/usr/bin/xset s off");

# disable DPMS
system("/usr/bin/xset -dpms");

# start Xfwm4
system("/usr/bin/xfwm4 --daemon");

sleep(3);

my $dpyinfo = `xdpyinfo`;

if ($dpyinfo =~ /dimensions:\s+(\d+)x(\d+)/) {
    system("/opt/firefox/firefox", "http://signage.union.rpi.edu/?mac=$MAC&w=$1&h=$2");
} else {
    # start firefox...
    system("/opt/firefox/firefox", "http://signage.union.rpi.edu/?mac=$MAC");
}



