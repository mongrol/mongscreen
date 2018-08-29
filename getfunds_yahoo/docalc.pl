# Calculate various stuff from fundamentals.

use warnings;
use strict;

use IO::Handle;
use LWP::Simple;
use DBI;
#use Text::CSV_XS;

my $url;
my $doc;              # our url result
my $logfile;          # filehandle for logfile;
my $dbh;              # database object
my ($query,$sth,$stu);# query vars

my ($d,$consensuseps1,$consensuseps2);

my ($epic, $price, $normeps, $pe, $prospe, $yield, $growth1, $growth2);
my ($cap, $netassets, $div, $credshort, $credlong, $cash, $gearing, $intangibles);
my ($pbv, $ptbv, $peg);

# connect to database
$dbh = DBI->connect('dbi:mysql:ftse:213.212.65.33:3306', "user", "pass");

open($logfile,'>',"logdaily.txt");


$query = "SELECT EPIC,Price,NormEPS,ConsensusEPS1,ConsensusEPS2,Netassets,Cap,Dividend,
          Creditorsshort,Creditorslong,Cash, Intangibles
            FROM current";
$sth = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
$sth->execute || die "execute: $query: $DBI::errstr";

while (($epic,$price,$normeps, $consensuseps1, $consensuseps2, $netassets, $cap,
        $div, $credshort, $credlong, $cash, $intangibles) = $sth->fetchrow_array())
    {
    print "$epic $price $normeps $consensuseps1\n";
    # do PE
    if ($normeps <= 0)
      { $pe = 0; }
    else
      { $pe = $price/$normeps; }
    # do Prospective PE
    if ($consensuseps1 <= 0)
      { $prospe = 0;}
    else
      { $prospe = $price/$consensuseps1; }
    # do yield
    if ($price <= 0)
      { $yield = 0; }
    else
      { $yield = $div/$price*100; }
    # do growth1 %
    if ($normeps <= 0)
        { $growth1 = 0; }
    else
        {
          $d = $consensuseps1 - $normeps;
          $growth1 = $d / $normeps * 100;
        }
    # do peg
    if ($growth1 <= 0)
        { $peg = 0;}
    else
        { $peg = $pe /$growth1; }
    # do growth2 %
    if ($consensuseps1 <= 0)
        { $growth2 = 0; }
    else
        {
          $d = $consensuseps2 - $consensuseps1;
          $growth2 = $d / $consensuseps1 * 100;
        }
    # do gearing %
    if ($netassets <= 0)
        { $gearing = 9999; }
    else
        {
          $gearing = ($credlong - $cash)/$netassets*100;
        }
    # do PBV
    if ($netassets <= 0)
        { $pbv = 9999; $ptbv = 9999; }
    else
        {
          $pbv = $cap/$netassets;
          if ($netassets-$intangibles <= 0)
            { $ptbv = 9999; }
          else
            { $ptbv = $cap/($netassets-$intangibles); }
        }
    print "$ptbv\n";
    
    $query = "UPDATE current SET
              PE='$pe',
              ProsPE='$prospe',
              EPSGrowth1='$growth1',
              EPSGrowth2='$growth2',
              Yield='$yield',
              Gearing='$gearing',
              PEG='$peg',
              PBV='$pbv',
              PTBV='$ptbv'
              WHERE EPIC='$epic'";
    $stu = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
    $stu->execute || die "execute: $query: $DBI::errstr";
    $stu->finish();
    
    }
    
