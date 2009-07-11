#!/usr/bin/env perl

use strict;
use warnings;

use POSIX;

POSIX::setsid( );


$ENV{"DISPLAY"} = ":0";
$ENV{"HOME"} = "/root";
$ENV{"LC_ALL"} = "C";

# auto-configure X server
if (defined $ENV{"xautoconfig"}) {
    system("dexconf -o /etc/X11/xorg.conf.orig");
    # remove BusID lines
    open my $file, "<", "/etc/X11/xorg.conf.orig" or die "failed to open input file";
    open my $outfile, ">", "/etc/X11/xorg.conf" or die "failed to open output file";
    while (<$file>) {
        # if the BusIDFail variable is defined, just copy it.
        # Otherwise, strip out BusID lines.
        unless (defined $ENV{"BusIDFail"}) {
            print $outfile $_ unless /BusID/;
        } else {
            print $outfile $_;
        }
    }
    close $file;
    close $outfile;
}

# clean mozilla crap
system("rm -rf /root/.mozilla");

# start X server and firefox
system("xinit /etc/xtasks.pl");


