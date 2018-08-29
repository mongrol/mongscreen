#!/usr/bin/perl -w

# This script accesses the Multex Investor website and attempts to extract the 
# forecast information for the specified EPIC.  The results are appended to 
# a timestamped file.

	#use strict;
	use LWP::Simple;
	use LWP::UserAgent;
	use HTTP::Cookies;
	use HTTP::Cookies::Mozilla;
		
sub extractmultexforecasts{

	# Parameters
	my $epic = shift();
	my $comp = shift();
	my $tstamp = shift();

	# Variables
	my $url = "";
	my $doc = "";
	my $opfile = "";
	my $logfile = "";
	my %miforecast = ();
	my $numkeyshsprice = 0;
	my $i = 0;
	my $ua = "";
	my $res = "";
	my @fdates = ();
	my @fdata = ();
	
	#print "Debug level: $debug \n";
	
	$ua = LWP::UserAgent->new;
	$ua->cookie_jar(HTTP::Cookies::Mozilla->new(
		file => "/root/.mozilla/default/75qdae8t.slt/cookies.txt", 
		autosave => 1));
		
	# Set output file with date and timestampwsMIFORECASTS.pl
	$opfile = $pathroot . 'miforecast' . $tstamp . '.txt';
	$logfile = $pathroot . 'miforecast' . $tstamp . '.log';
	
	$url = 'http://www.multexinvestor.co.uk/research/Earnings.asp?ticker=' . $epic . '.L';
	
	# Make up to five attempts to get the data
	for ( $i=0; ( ($i<5) and !($doc =~ /\Q$comp/) ); $i++ ) {
	#use object oriented approach
		$res = $ua->request(HTTP::Request->new(GET =>$url)) ;
		if ( $res->is_success) {
			$doc = $res->as_string;
		} 
	}
	
	printtofile ( $opfile, "$epic: $comp not found. \n", "append") if !($doc =~ /\Q$comp/);

	# Uncomment next line for debugging
	#printtofile( $logfile, $doc, "append" );
	# Uncomment next line to prevent processing
	#goto ENDSUB;

	# Check to see if there is any company information to extract
	if ( ($doc =~ /\Q$epic/) && ( $doc =~ /CONSENSUS ESTIMATES TRENDS/) ) {

		#Extract required section from $doc
		$doc =~ m/CONSENSUS ESTIMATES TRENDS(.*?)END CONSENSUS ESTIMATES TREND TABLE/s ;
		$doc = $1;
		print "$doc \n" if $debug ;
		
		# Find month and years for forecasts
		@fdates = $doc =~ m/Year&nbsp;Ending (\w{3}-\d{2})/g;
		
		# Find up to 2 unique dates and discard the rest
		if ($#fdates >= 1) { 
			$#fdates = 1;
			if ($fdates[0] eq $fdates[1]) { 
				$#fdates = 0;
				printtofile( $logfile, "$epic: $comp has only one set of forecasts i.e. 
					$fdates[0] \n", "append");
			}
			printtofile( $opfile, "$epic\t$comp\t$fdates[0]\t$fdates[1]\n", "append");
		}
		else {
			printtofile( $logfile, "$epic: $comp does not have forecast dates \n", "append");			
		}
		
		#foreach $fdate ( @fdates ) { print "$fdate \n"};
		
		# Extract the table information
		
		while ( $doc =~ m/<td class="mltxlboldtable">(.*?)<\/td>/g ) {
			@fdata = ();
			@fdata = ( $1,);
			for ( $i = 0; $i <= $#fdates; $i++ ) {
				$doc =~ m/\G(?:.*?)$fdates[$i](?:.*?)<td class="mltxrtable">(.*?)<\/td>/s;
				@fdata = ( @fdata, $1, );
			}
			SWITCH: {
				($fdata[0] =~ m/^Sales/i) && do {
					printtofile( $opfile, "S   \t$fdata[0]\t$fdata[1]\t$fdata[2]\n", "append");
					last SWITCH;
				};
				
				($fdata[0] =~ m/^Earnings/i) && do {
					printtofile( $opfile, "EPS \t$fdata[0]\t$fdata[1]\t$fdata[2]\n", "append");
					last SWITCH;
				};
				
				($fdata[0] =~ m/^Profit/i) && do {
					printtofile( $opfile, "P   \t$fdata[0]\t$fdata[1]\t$fdata[2]\n", "append");
					last SWITCH;
				};
				
				($fdata[0] =~ m/^Dividends/i) && do {
					printtofile( $opfile, "DPS \t$fdata[0]\t$fdata[1]\t$fdata[2]\n", "append");
					last SWITCH;
				};
				
				printtofile( $logfile, "$epic  $comp: Unknown data: $fdata[0] \n", "append");
				last SWITCH;
							
			}
					
		}
		printtofile( $opfile, "\n", "append");	
	}	
	else {
		printtofile( $logfile, "$epic: $comp no forecast data available. \n", "append");
	}
	
ENDSUB: {}				

}

		
#             End wsMIFORECASTS.pl
