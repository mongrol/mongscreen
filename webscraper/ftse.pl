#!/usr/bin/perl -w

	do "/root/bin/wstasks.pl";

	#Variables
	my @infotype = ( "alla", "fla", "aim" );
	my @info = ();
	my $tstamp = gettimestamp();
	my $sedol = "";
	my $epic = "";
	my $comp = "";
	my $infotype = "";
	my @ftsefiles = ();
	my $index = "";
	my $marcap = "";
	my $price = "";
	
	#Find the most recent file containing epic codes.
	foreach $infotype ( @infotype ) {

		$opfile = $pathroot . $infotype . $tstamp . '.txt';

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
			
			@info = ();
			@info = split( ",", $line );
			next if !$info[10] ;
			
			( $sedol =  $info[0] ) =~ s/^0+// ;
			$epic = $info[1];
			$comp = $info[2];
			$price = $info[8];
			$marcap = $info[10];
			$index = "Ineligible";
			
			SWITCH: {
				( $info[3] =~ m/UKX/ ) && do {
					$index = "FTSE 100";
					last SWITCH;
				};
			
				( $info[3] =~ m/MCX/ ) && do {
					$index = "FTSE 250";
					last SWITCH;
				};
			
				( $info[3] =~ m/SMX/) && do {
					$index = "FTSE SmallCap";
					last SWITCH;
				};
			
				( $info[3] =~ m/NSX/) && do {
					$index = "FTSE Fledgling";
					last SWITCH;
				};
			
				( $info[3] =~ m/AXX/) && do {
					$index = "AIM";
					last SWITCH;
				};
			
			}
			
			printtofile ( $opfile, "$comp,$epic,$sedol,$index,$price,$marcap \n", "append");
		}
	}
