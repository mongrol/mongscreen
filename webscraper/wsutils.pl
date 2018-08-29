#!/usr/bin/perl -w
# Defines global variables and
# miscellaneous sub-routines for use in the web-scraper application.

	# Global constants
	$pathroot = "/root/finance/webscraper/";

sub printtofile{

	my $filename = shift;
	my $report = shift;
	my $append = shift;
	
	$filename = '>' . $filename;
	$filename = '>' . $filename if $append;

	open (OUTFILE, $filename) or die "Could not open file $filename: $!\n";
	print OUTFILE $report;
	close OUTFILE;

}

sub gettimestamp{

	my @dt = gmtime();
	
	# $tstamp is in the format yymmddhhmm
	my $tstamp = substr((1900+$dt[5]),-2) . substr(("00" . (1+$dt[4])),-2) . 
		substr(("00" . $dt[3]),-2).substr(("00" . $dt[2]),-2).
		substr(("00" . $dt[1]),-2);

	return $tstamp
}
