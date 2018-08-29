
sub gethsbal{

  #$ua = LWP::UserAgent->new;
  $ua->cookie_jar(HTTP::Cookies::Mozilla->new(
                   File     => "cookies.txt",
                   AutoSave => 1,
               ));

  # get hsids from database
  $dbh = DBI->connect('dbi:mysql:ftse:213.208.89.139:3306', "screen", "ftse");
  $query = "SELECT hsid FROM current";
  $sth = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
  $sth->execute || die "execute: $query: $DBI::errstr";
  while ($hsid = $sth->fetchrow_array())
    {
    $url = "http://businessplus.hemscott.net/corp/crp". $hsid .".htm";
    print "$hsid : $url\n";

    my ($shortassets,$property,$intangibles,$fixedassets,$fixedinv,$stocks,$debtors,$cash,$credlong,$credshort) = 0;
    $doc = get($url);
    $te = new HTML::TableExtract();
        $te->parse($doc);
        foreach $ts ($te->table_states){
        foreach $row ($ts->rows) {
          if (@$row[0] =~ /norm earn per share|^earn per share/)
            {
            $normeps = @$row[6];
            if ($normeps =~ s/[\(|\)]//g) { $normeps = -$normeps }
            print "normeps is $normeps\n";
            }
          if (@$row[0] =~ /div per share/)
            {
            $div = @$row[6];
            print "Dividend is $div\n";
            }
          if (@$row[0] =~ /intangibles/)
            {
            $intangibles = @$row[6];
            print "intangibles is $intangibles\n";
            }
          if (@$row[0] =~ /property/)
            {
            $property = @$row[6];
            print "property is $property\n";
            }
          if (@$row[0] =~ /fixed assets/)
            {
            $fixedassets = @$row[6];
            print "fixedassets is $fixedassets\n";
            }
          if (@$row[0] =~ /investments/)
            {
            $fixedinv = @$row[6];
            print "fixed investments is $fixedinv\n";
            }
          if (@$row[0] =~ /^advances, debtors|^debtors/)
            {
            $debtors = @$row[6];
            print "debtors is $debtors\n";
            }
          if (@$row[0] =~ /^short term assets/)
            {
            $shortassets = @$row[6];
            print "shortassets is $shortassets\n";
            }
          if (@$row[0] =~ /^liquid assets, cash|^cash, securities|^cash/)
            {
            $cash = @$row[6];
            print "cash is $cash\n";
            }
          if (@$row[0] =~ /^stocks/)
            {
            $stocks = @$row[6];
            print "stocks is $stocks\n";
            }
          if (@$row[0] =~ /^creditors short/)
            {
            $credshort = @$row[6];
            print "credshort is $credshort\n";
            }
          if (@$row[0] =~ /^creditors long/)
            {
            $credlong = @$row[6];
            print "credlong is $credlong\n";
            }
        }
    }
    $netassets = $shortassets+$property+$intangibles+$fixedassets+$fixedinv+$stocks+$debtors+$cash-$credlong-$credshort;
    print "$netassets = $shortassets+$property+$intangibles+$fixedassets+$fixedinv+$stocks+$debtors+$cash-$credlong-$credshort\n";
    # Build query and insert row
    $query = "UPDATE current SET
            NormEPS = '$normeps',
            Dividend = '$div',
            Netassets = '$netassets',
            Intangibles = '$intangibles',
            Fixedassets = '$fixedassets',
            FixedInvestments = '$fixedinv',
            Stocks = '$stocks',
            Debtors = '$debtors',
            Cash = '$cash',
            Creditorsshort = '$credshort',
            Creditorslong = '$credlong'
            WHERE hsid='$hsid'";

    print "$hsid Done\n";
    $stu = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
    $stu->execute || die "execute: $query: $DBI::errstr";
    $stu->finish();
   }
$sth->finish();
$dbh->disconnect();
}

sub gethsum{

  # get hsids from database
  $dbh = DBI->connect('dbi:mysql:ftse:213.208.89.139:3306', "screen", "ftse");
  $query = "SELECT hsid FROM current";
  $sth = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
  $sth->execute || die "execute: $query: $DBI::errstr";
  while ($hsid = $sth->fetchrow_array())
    {
    $url = "http://www.hemscott.com/equities/company/c" . $hsid . "m.htm";
    print "$hsid : $url\n";
    $doc = get($url);
    $te = new HTML::TableExtract();
    $te->parse($doc);
    foreach $ts ($te->table_states(0,1)) {
      #print "Table (", join(',', $ts->coords), "):\n";
      foreach $row ($ts->rows) {
        if (@$row[0] =~ /SECTOR:/){
          $sector = @$row[1];
          $sector =~ s/^\s//;
          print "Sector is $sector\n";
          }
        if (@$row[0] =~ /INDEX:/){
          $index = @$row[1];
          print "Index is $index\n";
          }
        }
        $query = "UPDATE current SET Sector = '$sector' WHERE hsid='$hsid'";
        $stu = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
        $stu->execute || die "execute: $query: $DBI::errstr";
        $stu->finish();
        print done "Sector and its $sector";
      }
    }
$sth->finish();
$dbh->disconnect();
}

sub gethsid{
  # get EPICs from database
  $dbh = DBI->connect('dbi:mysql:ftse:213.208.89.139:3306', "screen", "ftse");
  $query = "SELECT EPIC FROM current";
  $sth = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
  $sth->execute || die "execute: $query: $DBI::errstr";
  #Loop around EPIC query gathering Hemscott ID's
  while ($epic = $sth->fetchrow_array())
    {
     $url ="http://hemscott.com/scripts/compsrch.dll/search?name=&epic=$epic&SrchSub=Search&URL=http%3A%2F%2Fwww.hemscott.com%2Fequities%2Fcompany%2Fcd%40COYID%40.htm&TARGET=TARGET%3D%22_top%22";
     print "$url\n";
     print "$epic : ";
     $doc = get($url);
     $doc =~ /cd[0-9]{5}/;
     $hsid = $&;
     $hsid =~ s/cd//;
     print "$hsid\n";
     $query = "UPDATE current SET hsid = '$hsid' WHERE EPIC='$epic'";
     $stu = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
     $stu->execute || die "execute: $query: $DBI::errstr";
     $stu->finish();
    }# while($epic);
$sth->finish();
$dbh->disconnect();
}
