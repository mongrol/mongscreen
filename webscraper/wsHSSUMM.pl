#!/usr/bin/perl -w

# This script accesses the Hemscott website and summary detail information.

	use LWP::Simple;
	#do "/root/bin/wsutils.pl";
	
sub extracthemsocottsumm{

	# Parameters
	my $hsid = shift();
	my $comp = shift();
	my $tstamp = shift();

	# Constants
	my $ss1 = '<tr><td><B>';
	my $ss2 = ':';
	my $ss2a = '</B></td><td>';
	my $ss3 = '</td></tr>';
	
	# Variables
	my $url = "";
	my $doc = "";
	my $opfile = "";
	my $logfile = "";
	my %hssum = ();
	my $i = 0;
	#my $initnumkeyshssum = 0;
	my $numkeyshssum = 0;
	
	# Set output file with date and timestamp
	$opfile = $pathroot . 'hssum' . $tstamp . '.txt';
	$logfile = $pathroot . 'hssum' . $tstamp . '.log';
	
	$url = 'http://www.hemscott.com/equities/company/c' . $hsid . 'm.htm';
	
	# Make up to five attempts to get the data
	for ( $i=0; ( ($i<5) and !($doc =~ /\Q$comp/) ); $i++ ) {
		$doc = get($url) ;
	}
	
	# Check to see if there is any company information to extract
	if ( $doc =~ /\Q$comp/ ) {
	
		#Write out the company ID
		printtofile( $opfile, ( $hsid . "\t" . $comp . "\n" ), "append" );
			
		#Extract fields and values
		while ( $doc =~ /$ss1/ ) {
			
			# Trim $doc to start of field info
			$doc =~ s/.*?$ss1//s ;
			
			# Extract field name ($1) and field value ( $2 )	
			if ( $doc =~ /(.*?)$ss2(?:.*?)$ss2a(.*?)$ss3/ ) {
				$hssum{"$1"} = "$2";				
			}
			
			# Trim $doc i.e. delete the field just extracted.
			$doc =~ s/.*?$ss3//s ;
			
		}
			
		foreach $key (sort keys %hssum ) {
			printtofile( $opfile, (" " . $key . "\t" . $hssum{$key} . "\n"), "append" ); 
		}
			
	}
	else {
		printtofile( $logfile, "$hsid: $comp not found. \n", "append");
	}
				
}
		
