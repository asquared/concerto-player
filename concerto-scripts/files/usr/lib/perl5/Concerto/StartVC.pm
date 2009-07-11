package Concerto::StartVC;

use POSIX;
use Carp;
use base Exporter;
our @EXPORT = qw/start_vc/;

# These 2 are OS-dependent...
my $TIOCSCTTY = 0x540e;
#my $SYS_ioctl = 54; 

open our $log, ">", "log.txt";

sub fail {
#    my $oldfh = select($log);
#    local $| = 1;
#    print @_;
#    select($oldfh);
    croak;
}

sub log_msg {
#    my $oldfh = select($log);
#    local $| = 1;
#    print @_;
#    select($oldfh);
}

sub start_vc {
    my $line = shift;
    my $cmd = shift;
    my $pid = fork( );
    if ($pid == -1) {
        croak "Failed to fork( ): $!";
    } elsif ($pid) {
        # parent process
        waitpid($pid, 0); # wait for the child to terminate
    } else {
        # child process

        # hopefully no errors after we do this...
        close(STDIN);
        close(STDOUT);
        close(STDERR);

        # start new session
        POSIX::setsid( );
        
        # open the TTY line
        my $fd = POSIX::open($line, &POSIX::O_RDWR);
        if ($fd == -1) {
            fail "Failed to open $line: $!";
        }

        # make the fd the controlling terminal
        open my $blah_fh, "<&=$fd";
        my $ret = ioctl($blah_fh, $TIOCSCTTY, 1);
        #my $ret = syscall($SYS_ioctl, $fd + 0, $TIOCSCTTY + 0, 1);

        log_msg("syscall returned $ret");

        # copy the FD over the 3 standard file descriptors
        POSIX::dup2($fd, 0) or fail "failed dup2 to stdin: $!"; # stdin
        POSIX::dup2($fd, 1) or fail "failed dup2 to stdout: $!"; # stdout
        POSIX::dup2($fd, 2) or fail "failed dup2 to stderr: $!"; # stderr

        $ENV{"TERM"} = "linux";

        log_msg("starting child process...");
        # execute the target command
        exec($cmd);
        log_msg("fail!");
    }
}

1;
