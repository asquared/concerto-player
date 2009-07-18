#!/usr/bin/env perl

use strict;
use warnings;

use Concerto::Signature qw/verify_sig/;
use LWP::Simple( );

# set volume levels
system("/usr/bin/amixer sset Master 0dB");
system('/bin/echo -e "VOLM30  \r" > /dev/ttyS0');

my $BASE_URL = "http://senatedev.union.rpi.edu/andrew/hardware/";

if (defined $ENV{'EMERG_AUDIO_BASE'}) {
    $BASE_URL = $ENV{'EMERG_AUDIO_BASE'};
}

# append trailing slash if missing
$BASE_URL =~ s|([^/])$|$1/|;

while (1) {
    # generate random challenge string
    my $chal;

    for (my $i = 0; $i < 32; ++$i) {
        $chal .= chr(ord('A') + rand(26));
    }


    #print "issuing HTTP request...\n";
    # request data from server
    my $data = LWP::Simple::get("${BASE_URL}audio.php?challenge_string=$chal");
    #print "got back response: $data\n";

    my ($sig, $url) = split /\n/, $data;
    if (verify_sig($chal . $url, $sig)) {
        if ($url ne 'none') {
            print "Playing emergency message: $url\n";
            # play the file
            system("/usr/bin/mpg123 $url");
            sleep 3;
        } else {
            # wait 15 seconds before trying again
            print "No emergency message (url=$url)\n";
            sleep 15;
        }
    } else {
        print "failed signature!\n";
        sleep 15;
    }
}




