#!/usr/bin/perl -w
#  $Id$  -*-cperl-*-

#=====================================================================
#
# DESCRIPTION
#   General paraframe server (example)
#
# AUTHOR
#   Jonas Liljegren   <jonas@paranormal.se>
#
# COPYRIGHT
#   Copyright (C) 2005-2006 Avisita AB.  All Rights Reserved.
#
#=====================================================================

our $APPROOT;
our $PFROOT;
our $WEBHOME;
our $WEBHOST;
our $PORT;

BEGIN
{
    our $VERSION  = sprintf("%d.%02d", q$Revision$ =~ /(\d+)\.(\d+)/);
    print "Starting ritguides $VERSION\n";

    use FindBin;
    use Cwd 'abs_path';

    $PFROOT = abs_path("$FindBin::Bin/../");
    $APPROOT = $FindBin::Bin;
    $WEBHOME = $ARGV[0] or die "Give the URL of the demo dir as an arg";
    if( $WEBHOME =~ s/:([^\/]+)// )
    {
	$PORT = $1;
	print "Port $PORT\n";
    }
    if( $WEBHOME =~ s/\/\/([^\/]+)// )
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
			    'appbase'     => 'Para::Frame::Demo',
			   });


    my $cfg =
    {
     'paraframe' => $PFROOT,
     'logfile'      => "/tmp/pf_demoserver-$PORT.log",
     'pidfile'      => "/tmp/pf_demoserver-$PORT.pid",
     'ttcdir'       => "/tmp",
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