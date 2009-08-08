package Concerto::SplashClient;

use strict;
use warnings;
use Socket;

require Exporter;

our @ISA = qw/Exporter/;
our @EXPORT_OK = qw/update_splash_text remove_splash_text update_splash_background end_splash/;

my $socket_available = 1;

socket(my $sock, PF_UNIX, SOCK_DGRAM, 0) or do {
    $socket_available = 0;
};

sub update_splash_text {
    return unless $socket_available;
    my ($msg) = @_;
    $msg = "#$msg";
    send($sock, $msg, 0, sockaddr_un("/dev/splash_screen"));
}

sub remove_splash_text {
    return unless $socket_available;
    send($sock, "#", 0, sockaddr_un("/dev/splash_screen"));
}

sub update_splash_background {
    return unless $socket_available;
    my ($new_bmp_path) = @_;
    send($sock, $new_bmp_path, 0, sockaddr_un("/dev/splash_screen"));
}

sub end_splash {
    return unless $socket_available;
    send($sock, "exit_server", 0, sockaddr_un("/dev/splash_screen"));
}

