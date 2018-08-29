# Mongfund2
use IO::Handle;
use DBI;
use HTML::TableExtract;
use LWP::Simple qw(get $ua);
use HTTP::Cookies;
use HTTP::Cookies::Mozilla;

$debug = 1;

  do 'mftse.pl';
  do 'mhem.pl';
  do 'myahoo.pl';
  do 'mcalc.pl';
  
#wipetable();
#getftseinfo("alla","fla","aim");
#gethsid();
#gethsum();
#gethsbal();
#getanal();
#getftseprices("alla","fla","aim");
docalc();

sub wipetable {
  #db connection
  $dbh = DBI->connect('dbi:mysql:ftse:213.208.89.139:3306', "screen", "ftse");
  # completely wipe table
  $query = "DELETE FROM current";
  $sth = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
  $sth->execute || die "execute: $query: $DBI::errstr";
  $dbh->disconnect();
}

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
