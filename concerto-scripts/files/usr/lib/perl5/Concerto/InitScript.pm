package Concerto::InitScript;

use strict;
use warnings;

use Concerto::SplashClient qw/update_splash_text/;

require Exporter;

our @ISA = qw/Exporter/;
our @EXPORT = qw/init_script log_and_splash/;

sub init_script {
    my $name = shift;
    update_splash_text($name);
}

sub log_and_splash {
    my $message = shift;
    print $message;
    update_splash_text($message);
}
