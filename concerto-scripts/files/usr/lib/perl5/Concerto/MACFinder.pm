package Concerto::MACFinder;

use Concerto::InterfaceFinder qw/choose_interface/;

use strict;
use warnings;

require Exporter;

our @ISA = qw/Exporter/;
our @EXPORT = qw/find_mac/;

sub find_mac {
    my $if = shift;
    unless (defined $if) {
        $if = choose_interface( ); 
    }
    my $ifconfig = `/sbin/ifconfig $if`;
    if ($ifconfig =~ /HWaddr (([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2})/) {
        return $1;
    }
}

