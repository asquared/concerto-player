#!/usr/bin/env perl

# sshd is dumb so its supervisory process must similarly be dumb :-)

use strict;
use warnings;

# check if the proper directory exists
unless (-d '/var/run/sshd') {
    mkdir '/var/run/sshd';
    chmod 0755, '/var/run/sshd';
}

# kill existing SSH processes
if (-r '/var/run/sshd.pid') {
    open my $pidfile, '<', '/var/run/sshd.pid';
    chomp(my $realpid = <$pidfile>);
    kill 9, $realpid;
    close $pidfile;
    unlink '/var/run/sshd.pid';
}

my $pid = fork( );
if ($pid) {
    # parent process 
    print "waiting for SSHD parent process $pid\n";
    waitpid($pid, 0);

    # check for presence of the pid file
    if (-r '/var/run/sshd.pid') {
        open my $pidfile, '<', '/var/run/sshd.pid';
        chomp(my $realpid = <$pidfile>);
        close $pidfile;
        print "sshd process $realpid seems to be running...\n";

        # poll the proc filesystem to determine if sshd is still alive
	while (-d "/proc/$realpid") {
            sleep 1;
        }
        print "process $realpid exited.\n";
    }
} else {
    # child process
    exec '/usr/sbin/sshd';
}

