#fetch yahoo epic data

use warnings;
use strict;

use IO::Handle;
use LWP::Simple;
use HTML::TableExtract;
use DBI;

my $epiclist;     # filehandle for epiclist
my $epic;
my $ecode;        # first letter of epic to form url to yahoo
my $url;
my $doc;          # our url result
my $logfile;      # filehandle for logfile;
my $outfile;      # filehandle for outputting html pages
my $dbh;          # database object
my ($query,$sth,$stu); # query vars

#data vars
my ($sector, $name, $normeps, $div, $consensus1, $consensus2, $cap);
my ($intangibles, $fixedass, $fixedinv, $stocks, $debtors, $cash);
my ($credshort, $credlong, $netassets);
my ($te, $ts, $row, $ind2, $count);

# connect to database
$dbh = DBI->connect('dbi:mysql:ftse:213.212.65.33:3306', "user", "pass");

#open epiclist
#open($epiclist,'epics.csv');
open($logfile,'>',"logfile.txt");

&wipetable;
&getepics;
&getfund;
&cleanup;

sub getfund {
#get epic list from db
$query = "SELECT EPIC FROM current";
$sth = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
$sth->execute || die "execute: $query: $DBI::errstr";


# main loop process for each EPIC
while ($epic = $sth->fetchrow_array())
    {
    print "-------------------------------Doing $epic \n";
    #fetch fundie profile
    $ecode = substr( $epic, 0, 1);
    $url = "http://uk.biz.yahoo.com/p/$ecode/$epic.html";
    $doc = get($url);
    print "$url\n";
    #open($outfile,'>',"$epic.html");
    #print $outfile $doc;
    if ($doc =~ /Document not found/ or $doc =~ /More Information/)
      {
      print $logfile "$epic: Incorrect Yahoo fund page at $url\n";
      next;
      }
    $doc =~ /Sector.+/;
    $sector = $&;
    $sector =~ s/Sector:<\/B>//; chomp ($sector);
    #print "$sector\n";

    # Company name
    $te = new HTML::TableExtract( depth => 1, count => 1 );
    $te->parse($doc);
    $ts = $te->table_state(1,1);
    #print "Table found at ", join(',', $ts->coords), "\n";
    foreach $row ($ts->rows) {
        $name = @$row[0];
        print "$name\n";
        }

    # Extract Balance Sheet
    $te = new HTML::TableExtract( depth => 1, count => 6 );
    $te->parse($doc);
    $fixedinv = 0; $netassets = 0;
    $intangibles = 0; $fixedass = 0;
    $fixedinv = 0 ; $stocks = 0;
    $debtors = 0; $cash = 0;
    $credlong = 0; $credshort = 0;
    foreach $ts ($te->table_states) {
      #print "Table found at ", join(',', $ts->coords), "\n";
      foreach $row ($ts->rows) {
        if (@$row[0] =~ /Norm/)
          { $normeps = @$row[4]; chomp($normeps); }
        if (@$row[0] =~ /Div per share/)
          { $div = @$row[4]; chomp($div); }
        if (@$row[0] =~ /Fixed asset/ && @$row[4] =~ /[0-9]/)
          { $fixedass = @$row[4]; chomp($fixedass); $fixedass =~ s/,//; }
        if (@$row[0] =~ /Fixed invest/ && @$row[4] =~ /[0-9]/)
          { $fixedinv = @$row[4]; chomp($fixedinv); $fixedinv =~ s/,//; }
        if (@$row[0] =~ /Stocks/ && @$row[4] =~ /[0-9]/)
          { $stocks = @$row[4]; chomp($stocks); $stocks =~ s/,//; }
        if (@$row[0] =~ /Debtors/ && @$row[4] =~ /[0-9]/)
          { $debtors = @$row[4]; chomp($debtors); $debtors =~ s/,//; }
        if (@$row[0] =~ /Cash/ && @$row[4] =~ /[0-9]/)
          { $cash = @$row[4]; chomp($cash); $cash =~ s/,//;}
        if (@$row[0] =~ /Intangibles/ && @$row[4] =~ /[0-9]/)
          { $intangibles = @$row[4]; chomp($intangibles); $intangibles =~ s/,//; }
        if (@$row[0] =~ /Creditors short/ && @$row[4] =~ /[0-9]/)
          { $credshort = @$row[4]; chomp($credshort); $credshort =~ s/,//; }
        if (@$row[0] =~ /Creditors long/ && @$row[4] =~ /[0-9]/)
          { $credlong = @$row[4]; chomp($credlong); $credlong =~ s/,//; }
        if (@$row[0] =~ /Mkt capit/)
          { $cap = @$row[4]; chomp($cap); $cap =~ s/,//; }

        }
      }
    # do balance sheet
    
    $netassets = $intangibles+$fixedass+$fixedinv+$stocks+$debtors+$cash-$credlong-$credshort;
    # Extract Analyst data
    $url = "http://uk.biz.yahoo.com/z/$ecode/$epic.html";
    $doc = get($url);
    if ($doc =~ /may no longer exist/)
      {
      print $logfile "$epic: No Yahoo Analyst page at $url\n";
      next;
      }
    $te = new HTML::TableExtract( depth => 1, count => 3 );
    $te->parse($doc);
    $ts = $te->table_state(1,3);
    foreach $row ($ts->rows) {
         if (@$row[0] =~ /Forecast Year 1/)
          {
          $consensus1 = @$row[2];
          #print "Consensus1 is $consensus1\n";
          }
          if (@$row[0] =~ /Forecast Year 2/)
          {
          $consensus2 = @$row[2];
          #print "Consensus2 is $consensus2\n";
          }

       }

    # Build query and insert row
    $query = "UPDATE current SET
            Sector = '$sector',
            NormEPS = '$normeps',
            ConsensusEPS1 = '$consensus1',
            ConsensusEPS2 = '$consensus2',
            Dividend = '$div',
            Netassets = '$netassets',
            Cap = '$cap',
            Intangibles = '$intangibles',
            Fixedassets = '$fixedass',
            FixedInvestments = '$fixedinv',
            Stocks = '$stocks',
            Debtors = '$debtors',
            Cash = '$cash',
            Creditorsshort = '$credshort',
            Creditorslong = '$credlong'
            WHERE EPIC='$epic'";
              
    print "$epic Done\n";
    $stu = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
    $stu->execute || die "execute: $query: $DBI::errstr";
    $stu->finish();
    }# while($epic);
$sth->finish();
}

sub getepics {
# slurp epic lists
  my $ind1 = "a", $ind2="0";
  
  foreach $ind1("a".."z")
  {
  for ($ind2=0;$ind2<10;$ind2++)
    {
    $url = "http://uk.biz.yahoo.com/p/uk/cpi/cpi$ind1$ind2.html";
    print "$url\n";
    $doc = get($url);
    if ($doc =~ /found/)
      {
      print $logfile "getepic(): End of $ind1 companies;\n";
      last;
      }
    if ($ind1=~ /k/)  # dodgy hack to get around tables moving coords
      {$count = 4;}
    else
      {$count = 5;}
    $te = new HTML::TableExtract( depth => 0, count => $count);
    $te->parse($doc);
    foreach $ts ($te->table_states){
    print "Table found at ", join(',', $ts->coords), "\n";
    foreach $row ($ts->rows){
      if (@$row[0]=~ /Companies/)
        {
        next; }
        $name = @$row[0];
        print "$name ";
        $epic = @$row[1];
        print "$epic\n";
        $query = "INSERT INTO current (EPIC, Name) VALUES ('$epic','$name')";
        $sth = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
        $sth->execute; # || die "execute: $query: $DBI::errstr";
        $sth->finish(); }
      }
    }
    }
    print $logfile "GetEpic(); successful";
}

sub wipetable {
  # completely wipe table
  $query = "DELETE FROM current";
  $sth = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
  $sth->execute || die "execute: $query: $DBI::errstr";
  print $logfile "Table current wiped";
}

sub cleanup {
  # deletes epics where sector = blank. ie: no analyst page.
  $query = "DELETE FROM current where Sector IS NULL";
  $sth = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
  $sth->execute || die "execute: $query: $DBI::errstr";
}


# close db
$dbh->disconnect();
close $logfile;


