package DownloadProgress;

use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request;
use Carp;

require Exporter;

our @ISA = qw/Exporter/;
our @EXPORT = qw/getstore_progress/;

sub getstore_progress {
    my ($url, $dest, $callback) = @_;
    my $ua = LWP::UserAgent->new;
    my $len;
    my $received = 0;

    open my $file, ">", $dest or croak "Failed to open $dest: $!";
    binmode $file;

    my $res = $ua->request(HTTP::Request->new(GET => $url),
        sub {
            my ($chunk, $res) = @_;
            $received += length($chunk);
            unless (defined $len) {
                $len = $res->content_length || 0;
            }
            
            if ($len) {
                print "$received/$len\r";
                &$callback($received, $len) if defined $callback;
            } else {
                print "$received\r";
                &$callback($received, 0) if defined $callback;
            }

            print $file $chunk;
        }
    );
    close $file;
}

1;
