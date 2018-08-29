#!/usr/bin/perl -w

	use strict;
	my $debug = 0;

# This is the master Hemscott webscraper script

	#do "/root/bin/wsutils.pl";
	do "/root/bin/wstasks.pl";

	gethsids();	
	gethsinfo("price");
	
#             End wsdaily.pl
