package Concerto::Signature;

use strict;
use warnings;

require Exporter;

our @ISA = qw/Exporter/;
our @EXPORT_OK = qw/load_key verify_sig/;

use Crypt::OpenSSL::RSA;
use MIME::Base64;

# load the RSA key from file
sub load_key {
    local $/ = undef;
    open my $keyfile, "<", "/initrd/mnt/public.key"
        or die("failed to open public key for signature verification");

    my $keystr = <$keyfile>;
    close $keyfile;

    # load the public key into OpenSSL
    return Crypt::OpenSSL::RSA->new_public_key($keystr);
}

sub verify_sig {
    my $value = shift;
    my $sig = shift;
    our $signage_key;

    if ($signage_key->verify($value, decode_base64($sig))) {
        return 1;
    } else {
        return 0;
    } 
}

our $signage_key = load_key( );

1;

