package Concerto::InterfaceFinder;

use strict;
use warnings;
use Exporter;

our @ISA = qw/Exporter/;
our @EXPORT_OK = qw/choose_interface is_wireless/;

sub choose_interface {
    my $iface;
    my $ifconfig = `/sbin/ifconfig -a`;
    my @cards;

    if (defined $ENV{"ETHERNET_CARD"}) {
        return $ENV{"ETHERNET_CARD"};
    }

    if (defined $ENV{"CARD_MAC"}) {
        my $mac = $ENV{"CARD_MAC"};
        @cards = ($ifconfig =~ /^((eth|ath|wlan)\d+)\s+Link encap:\w+\s+HWaddr $mac/);
    } else {
        @cards = ($ifconfig =~ /^((eth|ath|wlan)\d+)/gm);
    }

    if (scalar (@cards) > 0) {
        $iface = $cards[0];
        return $iface;
    } 

    # check if we actually found anything
    unless (defined $iface) {
        return undef;
    }
}

sub is_wireless {
    my $iface = shift;
    my $output = `/sbin/iwconfig $iface 2>&1`;
    if ($output =~ /no wireless extensions/) {
        return 0;
    } else {
        return 1;
    }
}
