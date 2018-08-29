#!/usr/bin/perl -w

# This script accesses the Hemscott website and attempts to extract the 
# 5yr results information for each HSID and then stores 
# them in a text file.

	use LWP::Simple;
	use LWP::UserAgent;
	use HTTP::Cookies;
	use HTTP::Cookies::Mozilla;
	
sub extracthemsocottresults{

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
	my $numkeyshsresults = 0;
	my $i = 0;
	my $yed = 0;
	my $yem = "";
	my $yearline = "";
	my @years = ();
	my @doclines = ();
	my @resfields = ();
	my $line = "";
	my $endofdata = 0;
	my %monnum = ();
	
	$ua = LWP::UserAgent->new;
	$ua->cookie_jar(HTTP::Cookies::Mozilla->new(
		file => "/root/.mozilla/default/75qdae8t.slt/cookies.txt", 
		autosave => 1));
		
	%monnum = (
		"jan" => "01",
		"feb" => "02",
		"mar" => "03",
		"apr" => "04",
		"may" => "05",
		"jun" => "06",
		"jul" => "07",
		"aug" => "08",
		"sep" => "09",
		"oct" => "10",
		"nov" => "11",
		"dec" => "12",
	);
		
	# Set output file with date and timestamp
	$opfile = $pathroot . 'hsresults' . $tstamp . '.txt';
	$logfile = $pathroot . 'hsresults' . $tstamp . '.log';
	
	$url = 'http://businessplus.hemscott.net/corp/crp' . $hsid . '.htm';
	
	# Make up to five attempts to get the data
	for ( $i=0; ( ($i<5) and !($doc =~ /\Q$comp/) ); $i++ ) {
	#use object oriented approach
		$res = $ua->request(HTTP::Request->new(GET =>$url)) ;
		if ( $res->is_success) {
			$doc = $res->as_string;
		} 
	}

	# Check to see if there is any company information to extract
	if ( ($doc =~ /\Q$comp/) && ( $doc =~ /year ended/) ) {

		#Extract values
		
		# Trim $doc to "year ended"
		$doc =~ s/.*?year ended//s ;
		
		printtofile( $logfile, $doc, "append" ) if $debug ;
		
		# Extract day and month of results
		$doc =~ m/(?: *)(\d+)(?: *)(\w+)/ ;
		$yed = $1 ;
		$yem = $2;
		# convert month name to month number
		$yem =~ m/(^\w{3})/ ;
		$yem = $monnum{(lc $1)};
		# correct for leap years
		if (($yed == 29) and ($yem == 2 )) { $yed = 28 };
		
		# Find the years for which results exist
		# Extract the first line
		$doc =~ m/\n/;
		$yearline = $`;
		$doc = $';
		@years = $yearline =~ m/(\d{4})/g;
		printtofile( $opfile, "$hsid \t $comp \n", "append");
		printtofile( $opfile, "\t\t", "append");
		foreach $year ( @years ) {
			printtofile( $opfile, "$yed/$yem/$year \t", "append");
		}
		printtofile( $opfile, "\n", "append");
		
		#split $doc into lines
	
		@doclines = split /\r\n|\n/, $doc;

		#split each line into fields and process them
		
		foreach $line ( @doclines ) {
			@resfields = ();
			@resfields = split / {2,}/, $line;
			$nodata = 0;

			SWITCH: {
				($resfields[0] =~ m/^turnover/i) && do {
					printtofile( $opfile, "TO  \t$resfields[1]\t", "append");
					last SWITCH;
				};
				
				($resfields[0] =~ m/^pre tax profit/i) && do {
					printtofile( $opfile, "PTP \t$resfields[1]\t", "append");
					last SWITCH;
				};
				
				($resfields[0] =~ m/^retained profit/i) && do {
					printtofile( $opfile, "RP \t$resfields[1]\t", "append");
					last SWITCH;
				};
				
				($resfields[0] =~ m/^norm earn per share/i) && do {
					printtofile( $opfile, "NEPS\t$resfields[1]\t", "append");
					last SWITCH;
				};
				
				($resfields[0] =~ m/^earn per share/i) && do {
					printtofile( $opfile, "EPS \t$resfields[1]\t", "append");
					last SWITCH;
				};
				
				($resfields[0] =~ m/^FRS3 earn per share/i) && do {
					printtofile( $opfile, "FEPS\t$resfields[1]\t", "append");
					last SWITCH;
				};
				
				($resfields[0] =~ m/^div per share/i) && do {
					printtofile( $opfile, "DPS \t$resfields[1]\t", "append");
					last SWITCH;
				};
				
				($resfields[0] =~ m/^intangibles/i) && do {
					printtofile( $opfile, "I   \t$resfields[1]\t", "append");
					last SWITCH;
				};
				
				($resfields[0] =~ m/^property/i) && do {
					printtofile( $opfile, "PROP\t$resfields[1]\t", "append");
					last SWITCH;
				};
				
				($resfields[0] =~ m/^fixed assets/i) && do {
					printtofile( $opfile, "FA  \t$resfields[1]\t", "append");
					last SWITCH;
				};
				
				($resfields[0] =~ m/^fixed investments|^investments/i) && do {
					printtofile( $opfile, "FI  \t$resfields[1]\t", "append");
					last SWITCH;
				};
				
				($resfields[0] =~ m/^advances, debtors|^debtors/i) && do {
					printtofile( $opfile, "A&D \t$resfields[1]\t", "append");
					last SWITCH;
				};
				
				($resfields[0] =~ m/^short term assets/i) && do {
					printtofile( $opfile, "STA \t$resfields[1]\t", "append");
					last SWITCH;
				};
				
				($resfields[0] =~ m/^liquid assets, cash|^cash, securities|^cash/i) && do {
					printtofile( $opfile, "LA&C\t$resfields[1]\t", "append");
					last SWITCH;
				};
				
				($resfields[0] =~ m/^stocks/i) && do {
					printtofile( $opfile, "S   \t$resfields[1]\t", "append");
					last SWITCH;
				};
#				
#				($resfields[0] =~ m/^debtors/i) && do {
#					printtofile( $opfile, "D   \t$resfields[1]\t", "append");
#					last SWITCH;
#				};
#				
#				($resfields[0] =~ m/^cash, securities/i) && do {
#					printtofile( $opfile, "C&S \t$resfields[1]\t", "append");
#					last SWITCH;
#				};
				
				($resfields[0] =~ m/^creditors short|^creditors/i) && do {
					printtofile( $opfile, "CS  \t$resfields[1]\t", "append");
					last SWITCH;
				};
				
				($resfields[0] =~ m/^creditors long/i) && do {
					printtofile( $opfile, "CL  \t$resfields[1]\t", "append");
					last SWITCH;
				};
				
				($resfields[0] =~ m/^subordinated loans|^loans/i) && do {
					printtofile( $opfile, "SL  \t$resfields[1]\t", "append");
					last SWITCH;
				};
				
				($resfields[0] =~ m/^long term ins funds/i) && do {
					printtofile( $opfile, "LTIF\t$resfields[1]\t", "append");
					last SWITCH;
				};
				
				($resfields[0] =~ m/^other ins funds/i) && do {
					printtofile( $opfile, "OIF \t$resfields[1]\t", "append");
					last SWITCH;
				};
				
				($resfields[0] =~ m/^prefs, minorities/i) && do {
					printtofile( $opfile, "P&M \t$resfields[1]\t", "append");
					last SWITCH;
				};
				
				($resfields[0] =~ m/^ord cap, reserves/i) && do {
					printtofile( $opfile, "OC&R\t$resfields[1]\t", "append");
					last SWITCH;
				};
				
				($resfields[0] =~ m/^mkt capitalisation/i) && do {
					printtofile( $opfile, "MC  \t$resfields[1]\t", "append");
					last SWITCH;
				};
				
				($resfields[0] =~ m/^<HR>/i) && do {
					$nodata = 1;
					last SWITCH;
				};
				
				($resfields[0] =~ m/^The above figures/i) && do {
					$endofdata = 1;
					last SWITCH;
				};
				
				($resfields[0] =~ m/^However, the latest/i) && do {
					$endofdata = 1;
					last SWITCH;
				};
				
				($resfields[0] =~ m/^Summary Detail/i) && do {
					$endofdata = 1;
					last SWITCH;
				};
				
				($resfields[0] =~ m/^<\/PRE>/i) && do {
					$endofdata = 1;
					last SWITCH;
				};
				
				($resfields[0] =~ m/^<br><P><br><P>/i) && do {
					$endofdata = 1;
					last SWITCH;
				};
				
				($resfields[0] =~ m/^<!--ENDHS-->/i) && do {
					$endofdata = 1;
					last SWITCH;
				};

				printtofile( $logfile, "$hsid  $comp: Unknown data: $resfields[0] \n", "append");
				$nodata = 1;
				last SWITCH;
							
			}
			
			last if $endofdata;
			next if $nodata;
			for ( $i=2 ; $i<=$#resfields ; $i++ ) {
				if ($resfields[$i] =~ m/gif/i) {
					printtofile( $opfile, "n/a\t", "append");
				}
				else {
					printtofile( $opfile, "$resfields[$i]\t", "append");
				}
			}
			printtofile( $opfile, "\n", "append");	
		}
		
		printtofile( $opfile, "\n", "append");	
	
		#goto ENDSUB;
				
	}
	else {
		printtofile( $logfile, "$hsid: $comp not found. \n", "append");
	}
	
ENDSUB: {}				

}

		
#             End webscraperHSPRICES.pl
