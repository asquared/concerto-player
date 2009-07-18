#!/usr/bin/env perl

use strict;
use warnings;

use Concerto::Signature qw/verify_sig/;
use Concerto::MACFinder qw/find_mac/;
use LWP::Simple( );

my $mac = find_mac('eth0');

#system('stty -F /dev/ttyS0 9600');

my $base_url = "http://signage.rpi.edu/";

if (defined $ENV{'CONCERTO_INSTALL'}) {
    $base_url = $ENV{'CONCERTO_INSTALL'};
}

while (1) {
    # generate random challenge string
    my $chal;

    for (my $i = 0; $i < 32; ++$i) {
        $chal .= chr(ord('A') + rand(26));
    }


    # request data from server
    my $data = LWP::Simple::get("${base_url}admin/screens/powerstate?mac=$mac&challenge_string=$chal");


    my ($sig, $cmd) = split /\n/, $data;
    my $powerstate = 'unknown';
    if (verify_sig($chal, $sig)) {
        if ($cmd eq 'on') {
            system('/etc/screen_on.pl');
            $powerstate = 'on';
        } elsif ($cmd eq 'off') {
            system('/etc/screen_off.pl');
            $powerstate = 'off';
        }
    }

    my @time = localtime;
    if ($powerstate eq 'off' || ($time[2] >= 3 && $time[2] <= 5)) {
        # try rebooting
        eval {
            open my $file, "<", "/proc/uptime" or die "failed to open file";
            my $line = <$file>;
            if ($line =~ /(\d+\.\d+)/) {
                if ($1 > 86400) {
                    # reboot the system
                    #print "REBOOTING SYSTEM... not!\n";
                    system("/sbin/reboot -f");
                }
            }
            close $file;
        }
    }
    sleep 15;
}

