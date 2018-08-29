#!/usr/bin/perl -w

	#use strict
	$debug = 0;

# This is the master Hemscott webscraper script

	#do "/root/bin/wsutils.pl";
	do "/root/bin/wstasks.pl";

	gethsinfo("summary");
	gethsinfo("results");
	getftseinfo("alla", "fla", "aim");
	getmiinfo("alla", "fla", "aim");

	
	
#             End wsweekly.pl
