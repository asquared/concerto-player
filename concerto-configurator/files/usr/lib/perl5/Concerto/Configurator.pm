package Concerto::Configurator;

use strict;
use warnings;

require Exporter;

use Concerto::MACFinder;
use Concerto::DownloadProgress qw/getstore_progress/;
use LWP::Simple( ); # don't import anything
use Crypt::OpenSSL::RSA; # for signature verification
use MIME::Base64;
use Digest::MD5;
use File::Copy;
use Storable;

our @ISA = qw/Exporter/;
our @EXPORT = qw/configure poll_card_update/;
#our $BASE_URL = "http://ds.rpitv.org/charliehorse/";
our $BASE_URL = "http://signage.union.rpi.edu/hardware/";
our $CARD_BASE = "/initrd/mnt";

sub get_summary {
    my $mac = shift;
    return LWP::Simple::get("$BASE_URL/config_summary.php?mac=$mac");    
}

sub get_commands {
    my $mac = shift;
    return LWP::Simple::get("$BASE_URL/config_commands.php?mac=$mac");
}

# load the RSA key from file
sub load_key {
    local $/ = undef;
    open my $keyfile, "<", "ds-public.key"
        or die("failed to open public key for signature verification");

    my $keystr = <$keyfile>;
    close $keyfile;

    # load the public key into OpenSSL
    return Crypt::OpenSSL::RSA->new_public_key($keystr);
}

our $signage_key = load_key( );

sub install_config {
    my $file_data = shift;
    my $target = shift;
    my $outfile;
    unless (open $outfile, ">", $target) {
        print "warning: failed to write config to $target\n";
        return;
    }

    print $outfile $file_data;
    close $outfile;

    if ($target =~ /\.pl$/) {
        chmod 0755, $target;
    }
}

# parse the summary and find the configurations to be loaded to ramdisk
sub find_configs {
    my $summary = shift;
    while ($summary =~ /^config_override:([^:]+):([^:]+):(.*)$/gm) {
        my $file = LWP::Simple::get($3); # get the data
        unless (defined $file) {
            next;
        }
        my $target = $1;
        my $sig = $2;
        if ($signage_key->verify($file, decode_base64($2))) {
            print "signature is good\n";
            print "(installing this to $target)\n";
            print "-->\n";
            print $file;
            print "\n<--\n";
            install_config($file, $target);
        } else {
            print "signature is not good (discarding file)\n";
        }
    }
}

# compute the MD5 hash of a file
sub md5file {
    my $infile = shift;
    open my $fh, '<', $infile or die "Failed to open file $infile to get MD5 hash: $!";
    my $md5ctx = Digest::MD5->new( );
    $md5ctx->addfile($fh);
    close($fh);
    return $md5ctx->hexdigest( );   
}


# parse the summary file and search for flash card updates
sub find_card_files {
    my $summary = shift;
    my $db;
    if (-r "$CARD_BASE/version.dat") {
        $db = retrieve("$CARD_BASE/version.dat");
    } else {
        $db = { };
    }
    my $dbflag = 0;

    my $warnflag = 0;

    while ($summary =~ /^file:([^:]+):([^:]+):([0-9a-f]+):(.*)$/gm) {
        my $url = $4;
        my $output_path = $1;
        my $sig = $2;
        my $md5hash = $3;

        if (!$warnflag) {
            $warnflag = 1;
            print <<EOF
*******************************************************************************
*******************************************************************************
**                                                                           **
**                      ! !      W A R N I N G      ! !                      **
**                                                                           **
**  The system Flash is currently being updated with the latest Concerto     **
**  software. Please wait until the process is complete before shutting      **
**         down or rebooting this system. Please be patient!                 **
**                                                                           **
**                      ! !      W A R N I N G      ! !                      **
**                                                                           **
*******************************************************************************
*******************************************************************************
EOF
;
    
            #system("splash -s -u 0 /etc/splash/warning.cfg");
        }

        # check file MD5 against database
        if (defined $db->{$output_path} && $db->{$output_path} eq $md5hash) {
            next; # we already have this file locally
        }

        # if they are different then load the new file
        print "retreiving $url to download.tmp...";
        unless (getstore_progress($url, "$CARD_BASE/download.tmp") == 200) {
            next; # failure to get the file
        }
        
        # verify the MD5 hash of the file
        unless (md5file("$CARD_BASE/download.tmp") eq $md5hash) {
            print "md5 failed for flash update file $output_path";
            next;
        }

        # verify the digital signature (but on the MD5 hash instead of the whole file)
        if ($signage_key->verify($md5hash, decode_base64($2))) {
            print "signature OK, installing $output_path to card";

            # rename old junk files
            if (-e "$CARD_BASE/$output_path") {
                unlink("$CARD_BASE/$output_path".".bak");
                move("$CARD_BASE/$output_path", "$CARD_BASE/$output_path".".bak");
            }

            # move file to its final location
            move("$CARD_BASE/download.tmp", "$CARD_BASE/$output_path");
            # update the database
            $db->{$output_path} = $md5hash; 
            $dbflag = 1;
        } else {
            print "signature is not good (discarding file)\n";
            unlink "$CARD_BASE/download.tmp";
        }
    }
    print "Flash update complete.\n";

    #system("splash -s -u 0 /etc/splash/normal.cfg");

    # store the database to card if any changes were made
    if ($dbflag) {
        store $db, "$CARD_BASE/version.dat";
    }
}

sub configure {
    my $summary;
    until (defined $summary) {
        $summary = get_summary(find_mac("eth0"));
    }
    
    find_configs($summary);
    unless (defined $ENV{"cdboot"}) {
        find_card_files($summary);
    }
}

sub poll_card_update {
    my $summary;
    $summary = get_summary(find_mac("eth0"));
    unless (defined $summary) {
        return;
    }
    find_card_files($summary);
}

sub do_commands {
    my $commands = shift;
    # for each line in $commands
    # do the command
    #
}

1;
