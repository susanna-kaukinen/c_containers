#!/usr/bin/perl -Tw

use strict;
use Socket;
use Carp;
use Sys::Hostname;
use POSIX ":sys_wait_h";
use Errno;

$SIG{CHLD} = \&REAPER;

my $waitedpid = 0;

sub spawn;

sub logmsg 
{ 
	print "$0 $$: @_ at ", scalar localtime, "\n" 
}

sub REAPER
{
	local $!; # don't let waitpid() overwrite current error

	while ((my $pid = waitpid(-1,WNOHANG)) > 0 && WIFEXITED($?)) {
		#logmsg "reaped $waitedpid" ($? ? " with exit $?" : '');
		logmsg "reaped $waitedpid";
	}

	$SIG{CHLD} = \&REAPER; # loathe SysV
}

sub close_socket
{

	print ("Closing socket\n");

	$_[0]->close();

}

sub feed_file {
	
	open (MYFILE, '/etc/hosts');

	print ("<hosts>\n");
	while (<MYFILE>) {
		chomp;
		print ("$_\n");
	}
	print ("</hosts>\n");

	close (MYFILE); 

}

sub server_loop
{
	my $server=shift;

	while(1) {

		my $paddr = accept(Client, $server) || do {
			next if $!{EINTR}; # try again if accept() returned because a signal was received
			die "accept: $!";
		};

		my ($port, $iaddr) = sockaddr_in($paddr);
		my $name = gethostbyaddr($iaddr, AF_INET);

		logmsg "connection from $name [", inet_ntoa($iaddr), "] at port $port";

		spawn sub {
			$|=1;

			my $buf;

			while (defined($buf = <Client>)) {
				chop $buf;
				foreach ($buf) {
					/^HELLO$/ and
						print("Hi\n"), last;
					/^NAME$/  and
						print(hostname(),"\n"), last;
					/^DATE$/  and
						print(scalar(localtime), "\n"), last;
					/^foo$/	and
						feed_file(), last;
					/^exit$/ and
						print "Bye.\n", close Client, last;

				# default:
					print Client "DEFAULT\n";
				}
			}
			print "Kid gone\n";
		};
		
		close Client;
	}
}

sub spawn
{
	my $coderef = shift;

	unless (@_ != 1 && $coderef && ref($coderef) eq 'CODE') {
		confess "usage: spawn CODEREF";
	}

	if (! defined(my $pid = fork)) {
		logmsg "cannot fork: $!";
		return;
	}
	elsif ($pid) { # parent
		logmsg "begat $pid";
		return; 
	}

	#<child>

	open(STDIN, "<&Client") || die "can't dup client to stdin";
	open(STDOUT, ">&Client") || die "can't dup client to stdout";
	## open(STDERR, ">&STDOUT") || die "can't dup stdout to stderr";

	exit &$coderef();

	#</child>
}

sub main
{
	my $server;
	my $port  = shift || 2345;
	my $proto = getprotobyname('tcp');

	($port) = $port =~ /^(\d+)$/ or die "invalid port";

	socket     ($server, PF_INET,    SOCK_STREAM,  $proto)        || die "socket: $!";
	setsockopt ($server, SOL_SOCKET, SO_REUSEADDR, pack("l", 1))  || die "setsockopt: $!";
	bind       ($server, sockaddr_in($port, INADDR_ANY))          || die "bind: $!";
	listen     ($server, SOMAXCONN)                               || die "listen: $!";

	logmsg "server started on port $port";

	server_loop($server)
}

main
