#fetch yahoo daily data

use warnings;
use strict;

use IO::Handle;
use LWP::Simple;
use DBI;
#use Text::CSV_XS;

my $url;
my $doc;          # our url result
my $logfile;      # filehandle for logfile;
my $dbh;          # database object
my ($query,$sth,$stu); # query vars

my $daily;        # filehandle
my $line;


my ($epic, $mid, $bid, $ask);

# connect to database
$dbh = DBI->connect('dbi:mysql:ftse:213.208.89.139:3306', "screen", "ftse");

open($logfile,'>',"logdaily.txt");


$query = "SELECT EPIC FROM current";
$sth = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
$sth->execute || die "execute: $query: $DBI::errstr";

while ($epic = $sth->fetchrow_array())
    {
    &getquotes ("http://uk.finance.yahoo.com/d/quotes.csv?s=$epic&f=sl1ba&e=.csv");
    print $logfile "$epic Done\n";
    }

&cleanup;
    
sub getquotes {
  my ($url) = @_;
  $doc = get($url);
  open($daily,'>',"outdaily.txt");
  print $daily "$doc\n \n"; close $daily;
  open($daily,"outdaily.txt");
  foreach $line (readline($daily))
    {
    if ($line =~ s/\w.+//)
      {
      $line = $&; $line =~ s/"//;
      #print "$line\n";
      ($epic, $mid, $bid, $ask) = split(",",$line);
      print "$epic $mid $bid $ask\n";
      &updatedb;
      }
    }
}

sub updatedb {
  # enter prices in db
  $query = "UPDATE current SET Price = '$mid' WHERE EPIC='$epic'";
  $stu = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
  $stu->execute || die "execute: $query: $DBI::errstr";
  $stu->finish();
}

sub cleanup {
  # deletes epics where price zero. ie: company defunct.
  $query = "DELETE FROM current where price = 0";
  $sth = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
  $sth->execute || die "execute: $query: $DBI::errstr";
}

# close db
$dbh->disconnect();
