#!/usr/bin/perl -w
# -*-cperl-*-
#=============================================================================
#
# DESCRIPTION
#   General paraframe server (example)
#
# AUTHOR
#   Jonas Liljegren   <jonas@paranormal.se>
#
# COPYRIGHT
#   Copyright (C) 2005-2009 Avisita AB.  All Rights Reserved.
#
#=============================================================================

use 5.010;
use strict;
use warnings;

our $APPROOT;
our $PFROOT;
our $WEBHOME;
our $WEBHOST;
our $PORT;

BEGIN
{
    print "Starting ritguides\n";

    unless( @ARGV )
    {
	print "Give the URL of the demo dir as an arg\n";
	print "Example: demoserv.pl //demo.com/~myplace\n";
	exit;
    }

    use FindBin;
    use Cwd 'abs_path';

    $PFROOT = abs_path("$FindBin::Bin/../");
    $APPROOT = $FindBin::Bin;
    $WEBHOME = $ARGV[0];
    $PORT = 7788;
    if( $WEBHOME =~ s/:([^\/]+)// ) # Parses out port from command line
    {
	$PORT = $1;
	print "Port $PORT\n";
    }
    if( $WEBHOME =~ s/\/\/([^\/]+)// ) # Parses out webhost from command line
    {
	$WEBHOST = $1;
	print "Host $WEBHOST\n";
    }

    print "Home $WEBHOME\n";
}

use strict;
use locale;

use lib "$PFROOT/lib";
use lib "$APPROOT/lib";


use Para::Frame;
use Para::Frame::DBIx;
use Para::Frame::Watchdog;
use Para::Frame::Site;

{
    Para::Frame::Site->add({
			    'code'        => 'demo',
			    'webhome'     => $WEBHOME,
			    'webhost'     => $WEBHOST,
			   });


    my $cfg =
    {
     'paraframe' => $PFROOT,
     'appbase'      => 'Para::Frame::Demo',
     'logfile'      => "/tmp/pf_demo/server-$PORT.log",
     'pidfile'      => "/tmp/pf_demo/server-$PORT.pid",
     'ttcdir'       => "/tmp/pf_demo",
     'approot'      => $APPROOT,
     'port'         => $PORT,
     'debug'        => $ARGV[1] || 0,
    };
    Para::Frame->configure( $cfg );


    if( not $ARGV[1] )
    {
        Para::Frame->daemonize(1);
    }
    else
    {
	Para::Frame->watchdog_startup();
    }
  }

#########################################################
