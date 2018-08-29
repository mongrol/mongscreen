#!/usr/bin/perl -w

	#use strict

# The main Hemscott webscraper tasks are contained in this script

	do "/root/bin/wsutils.pl";
	do "/root/bin/wsHSIDs.pl";
	do "/root/bin/wsHSSUMM.pl";
	do "/root/bin/wsHSPRICE.pl";
	do "/root/bin/wsHSRESULTS.pl";
	do "/root/bin/wsMIFORECASTS.pl";

sub getftsechanges {

	use LWP::Simple;
	use LWP::UserAgent;
	use HTTP::Cookies;
	use HTTP::Cookies::Mozilla;

	# Parameters
	my ($year) = @_;
	
	# variables
	my $ua = "";
	my $opfile = "";
	my $logfile = "";
	my $url = "";
	my $res = "";	
	my $getok = "";

	$ua = LWP::UserAgent->new;
	$ua->cookie_jar(HTTP::Cookies::Mozilla->new(
		file => "/root/.mozilla/default/75qdae8t.slt/cookies.txt", 
		autosave => 1));
		
	$year = substr($year, -2);
	$opfile = $pathroot . "uk$year" . '.html';
	$logfile = $pathroot . "uk$year" . '.log';
	$url = "http://www.ftse.com/indices_marketdata/index_notes/uk$year.html";

	print "$url \n" if $debug;
		

	# Make up to five attempts to get the data
	for ( $i=0; (($i<5) and !$getok) ; $i++ ) {
		print "$year: attempt $i\n" if $debug;
		$res = $ua->request(HTTP::Request->new(GET =>$url), $opfile) ;
		if ( $res->is_success) {
			$getok = "ok";
		}
		else {
			printtofile ( $logfile, 
				"Error getting ftse change data: $res->status_line\n", "append");
		}
	}

}

sub getftseinfo {

	use LWP::Simple;
	use LWP::UserAgent;
	use HTTP::Cookies;
	use HTTP::Cookies::Mozilla;

	# Parameters
	my (@infotype) = @_;
	
	# variables
	my $ua = "";
	my $opfile = "";
	my $logfile = "";
	my $url = "";
	my $res = "";	
	my $tstamp = gettimestamp();	
	my $getok = "";
	my $infotype = "";
	

	$ua = LWP::UserAgent->new;
	$ua->cookie_jar(HTTP::Cookies::Mozilla->new(
		file => "/root/.mozilla/default/75qdae8t.slt/cookies.txt", 
		autosave => 1));
	
	foreach $infotype ( @infotype ) {
		
		# Set output file with date and timestamp
		$opfile = $pathroot . "ftse$infotype" . $tstamp . '.txt';
		$logfile = $pathroot . "ftse$infotype" . $tstamp . '.log';
		$url = "http://www.ftse.com/objects/csv_to_csv.jsp?"
			. "infoCode=$infotype"
			. "&theseColumns=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19";
			
		print "$url \n" if $debug;
		
		$getok = "";
		# Make up to five attempts to get the data
		for ( $i=0; (($i<5) and !$getok) ; $i++ ) {
			print "$infotype: attempt $i\n" if $debug;
			$res = $ua->request(HTTP::Request->new(GET =>$url), $opfile) ;
			if ( $res->is_success) {
				$getok = "ok";
			}
			else {
				printtofile ( $logfile, 
					"Error getting ftse data $infotype: $res->status_line\n", "append");
			}
		}
	}
}
	
sub gethsids {
	
	my $tstamp = gettimestamp();
		
	foreach ( (A..Z) ) {
	
		extracthemscottid( $_, $tstamp );	
	
	}
	
}

sub gethsinfo {

	# Parameters
	my ($infotype) = @_;
	
	#Variables
	my $tstamp = gettimestamp();
	my $hsid = "";
	my $comp = "";
	my @hsidfiles = ();

	#Find the most recent file containing hemscott ids.
	opendir HSIDDIR, $pathroot;
	@hsidfiles = reverse sort grep /hsid/, readdir HSIDDIR;			
	closedir HSIDDIR;
	
	#Open the file
	open (HSIDFILE, "<$pathroot$hsidfiles[0]") or 
		die "Could not open file $hsidfiles[0]: $!\n";
	
	#Read each line, extract the HSID, and then extract the required
	#information from the web.
	
	while ( $line = <HSIDFILE> ) {
		( $hsid, $comp ) = split( ",", $line );
		#Remove CRs and LFs
		$comp =~ s/\n//s;
		$comp =~ s/\r//s;
		#print "$hsid \n";
		
		#print "Infotype is: $infotype \n";
		extracthemsocottsumm( $hsid, $comp, $tstamp ) if $infotype eq "summary";
		extracthemsocottprice( $hsid, $comp, $tstamp ) if $infotype eq "price";
		extracthemsocottresults( $hsid, $comp, $tstamp ) if $infotype eq "results";

		last if $debug;
	}
	
	close HSIDFILE;

}

sub getmiinfo {

	# Parameters
	my @infotype = @_;
	
	#Variables
	my $tstamp = gettimestamp();
	my $sedol = "";
	my $epic = "";
	my $comp = "";
	my $infotype = "";
	my @ftsefiles = ();
	
	#Find the most recent file containing epic codes.
	foreach $infotype ( @infotype ) {
		@ftsefiles = ();
		opendir FTSEDIR, $pathroot;
		@ftsefiles = reverse sort grep /ftse$infotype/, readdir FTSEDIR;			
		closedir FTSEDIR;
	
		#Open the file
		open (FTSEFILE, "<$pathroot$ftsefiles[0]") or 
			die "Could not open file $ftsefiles[0]: $!\n";
	
		#Read each line, extract the EPIC, and then extract the required
		#information from the web.
	
		while ( $line = <FTSEFILE> ) {
	
			( $sedol, $epic, $comp ) = split( ",", $line );
			#remove trailing "." from $epic if it has one.
			$epic =~ s/\Q.// if $epic;	
			print "getmiinfo: $epic \n" if $debug;
			extractmultexforecasts( $epic, $comp, $tstamp ) if $epic;
		}
	}
}
	
#             End wstasks.pl
