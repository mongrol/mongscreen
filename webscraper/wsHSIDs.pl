#!/usr/bin/perl -w

# This script accesses the Hemscott website and attempts to extract the following information:
#	Company Names
#	Hemscott IDs
# and then stores them in a text file.

	use LWP::Simple;
	#do "/root/bin/wsutils.pl";
		
sub extracthemscottid{

	# Parameters
	my $URL = 'http://www.hemscott.com/equities/ATOZ_' . shift() . '.HTM';
	my $tstamp = shift();

	# Constants
	my $ss1 = 'company/cd';
	my $ss2 = '.htm';
	my $ss3 = '>';
	my $ss4 = '<';
	
	# Variables
	my $doc = "";
		
	# Create output file with date and timestamp
	my $opfile = $pathroot . 'hsid' . $tstamp . '.txt';
	
	# Make up to five attempts to get the data
	for ( $i=0; ( ($i<5) and !($doc =~ /$ss1/) ); $i++ )
		{
		$doc = get($URL) ;
		}
	
	# Check to see if there is any company information to extract
	while ( $doc =~ /$ss1/ )
		{
		
		# Trim $doc to start of company ID
		$doc =~ s/.*?$ss1//s ;
		
		# Extract company Hemscott ID ($1) and company name ( $3 )	
		if ( $doc =~ /(.*?)$ss2(.*?)$ss3(.*?)$ss4/ )
			{
			printtofile($opfile,$1 . ",". $3 . "\n", "append");
			}

		# Trim $doc i.e. delete the company just extracted.
		$doc =~ s/.*?$ss4//s ;
		
		}
}
		
#             End webscraperHSIDs.pl
