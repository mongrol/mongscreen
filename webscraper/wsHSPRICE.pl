#!/usr/bin/perl -w

# This script accesses the Hemscott website and attempts to extract the 
# daily closing price information for each HSID and then stores 
# them in a csv file.

	use LWP::Simple;
	use LWP::UserAgent;
	use HTTP::Cookies;
	#do "/root/bin/wsutils.pl";
	#do "/root/bin/Mozilla.pm";
	
sub extracthemsocottprice{

	# Parameters
	my $hsid = shift();
	my $comp = shift();
	my $tstamp = shift();

	# Variables
	my $url = "";
	my $doc = "";
	my $opfile = "";
	my $logfile = "";
	my %hsprice = ();
	my $numkeyshsprice = 0;
	my $i = 0;
	
	$ua = LWP::UserAgent->new;
	$ua->cookie_jar(HTTP::Cookies::Mozilla->new(
		file => "/root/.mozilla/default/75qdae8t.slt/cookies.txt", 
		autosave => 1));
		
	# Set output file with date and timestamp
	$opfile = $pathroot . 'hsprice' . $tstamp . '.txt';
	$logfile = $pathroot . 'hsprice' . $tstamp . '.log';
	
	$url = 'http://businessplus.hemscott.net/price/pri' . $hsid . '.htm';
	
	# Make up to five attempts to get the data
	for ( $i=0; ( ($i<5) and !($doc =~ /\Q$comp/) ); $i++ ) {
	#use object oriented approach
		$res = $ua->request(HTTP::Request->new(GET =>$url)) ;
		if ( $res->is_success) {
			$doc = $res->as_string;
		} 
	}

	# Uncomment next line for debugging
	#printtofile( $logfile, $doc, "append" );
	# Uncomment next line to prevent processing
	#goto ENDSUB;
	

	# Check to see if there is any company information to extract
	if ( $doc =~ /\Q$comp/ ) {

		#Extract values
		
		if ( $doc =~ m/(?:.*?)Closing Share price on (.*?)(?: *?):<b>(?: *)(.*?)(.)<\/b>/is ) {
			$hsprice{"DATE"} = $1;
			$hsprice{"CLOSING PRICE"} = "$2 $3";
			# Uncomment next line for debugging.
			#print "$hsid Date: $1 Price: $2 $3 \n";
		}
		
		if ( $doc =~ m/(?:.*?)No of shares in issue(?: *?):<b>(?: *)(.*?)(.)<\/b>/is ) {
			$hsprice{"NO OF SHARES"} = "$1 $2";
			# Uncomment next line for debugging.
			#print "      No. of shares: $1 $2 \n";
		}
		
		if ( $doc =~ m/(?:.*?)Market Capitalisation(?:.*?):<b>(?: *)(\D*)(.*?)(.)<\/b>/is ) {
			$hsprice{"MARKET CAP"} = "$1 $2 $3";
			# Uncomment next line for debugging.
			#print "      Market Capitalisation: $1 $2 $3 \n";
		}
		
		
		#O/P information extracted.
		printtofile( $opfile, ($hsid . "\t" . $comp . "\n"), "append" ); 			
		foreach $key (sort keys %hsprice ) {
			printtofile( $opfile, " " . $key . "\t" . ($hsprice{$key} . "\n"), "append" ); 
		}
			
	}
	else {
		printtofile( $logfile, "$hsid: $comp not found. \n", "append");
	}
	
ENDSUB: {}				

}

		
#             End webscraperHSPRICES.pl
