
sub gethsbal{

  #$ua = LWP::UserAgent->new;
  $ua->cookie_jar(HTTP::Cookies::Mozilla->new(
                   File     => "cookies.txt",
                   AutoSave => 1,
               ));

  # get hsids from database
  $dbh = DBI->connect('dbi:mysql:ftse:213.208.89.139:3306', "screen", "ftse");
  $query = "SELECT hsid FROM current where EPIC like 'CTO'";
  $sth = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
  $sth->execute || die "execute: $query: $DBI::errstr";
  while ($hsid = $sth->fetchrow_array())
    {
    $url = "http://businessplus.hemscott.net/corp/crp". $hsid .".htm";
    print "$hsid : $url\n";

    $doc = get($url);
    # Trim $doc to "year ended"
		#$doc =~ s/.*?year ended//s ;
    #$doc =~ /\<pre\>(.*\n)<\/pre\>/is;
    #$doc = $1;
    #$doc =~ s/.*?year ended//s ;
    #print $doc;
    $logfile = "log.txt";
    $append = TRUE;
    @doclines = split /\r\n|\n/, $doc;
    my ($shortassets,$property,$intangibles,$fixedassets,$fixedinv,$stocks,$debtors,$cash,$credlong,$credshort) = 0;
    foreach $line ( @doclines ) {
			@resfields = ();
			@resfields = split / {2,}/, $line;
      SWITCH: {

#        ($resfields[0] =~ m/^turnover/i) && do {
#          $turnover = $resfields[$#resfields];
#					last SWITCH;
#				};

#				($resfields[0] =~ m/^pre tax profit/i) && do {
#          $pretaxprofit = $resfields[$#resfields];
#					last SWITCH;
#				};

#				($resfields[0] =~ m/^retained profit/i) && do {
#          $turnover = $resfields[$#resfields];
#					last SWITCH;
#				};

         ($resfields[0] =~ m/^norm earn per share/i) && do {
          $normeps = $resfields[$#resfields];
          print "$normeps --- \n";
					last SWITCH;
				};

#				($resfields[0] =~ m/^earn per share/i) && do {
#          $eps = $resfields[$#resfields];
#					last SWITCH;
#				};

#				($resfields[0] =~ m/^FRS3 earn per share/i) && do {
#          $frs3eps = $resfields[$#resfields];
#					last SWITCH;
#				};

				($resfields[0] =~ m/^div per share/i) && do {
          $div = $resfields[$#resfields];
					last SWITCH;
				};

				($resfields[0] =~ m/^intangibles/i) && do {
          $intangibles = $resfields[$#resfields];
					last SWITCH;
				};

				($resfields[0] =~ m/^property/i) && do {
          $property = $resfields[$#resfields];
					last SWITCH;
				};

				($resfields[0] =~ m/^fixed assets/i) && do {
          $fixedassets = $resfields[$#resfields];
          print "fixed assets = $fixedassets\n";
					last SWITCH;
				};

				($resfields[0] =~ m/^fixed investments|^investments/i) && do {
          $fixedinv = $resfields[$#resfields];
					last SWITCH;
				};

				($resfields[0] =~ m/^advances, debtors|^debtors/i) && do {
          $debtors = $resfields[$#resfields];
					last SWITCH;
				};

				($resfields[0] =~ m/^short term assets/i) && do {
          $shortassets = $resfields[$#resfields];
					last SWITCH;
				};

				($resfields[0] =~ m/^liquid assets, cash|^cash, securities|^cash/i) && do {
          $cash = $resfields[$#resfields];
					last SWITCH;
				};

				($resfields[0] =~ m/^stocks/i) && do {
          $stocks = $resfields[$#resfields];
					last SWITCH;
				};

				($resfields[0] =~ m/^creditors short/i) && do {
          $credshort = $resfields[$#resfields];
          print "credshort = $credshort\n";
          last SWITCH;
				};

				($resfields[0] =~ m/^creditors long/i) && do {
          $credlong = $resfields[$#resfields];
					last SWITCH;
				};

#				($resfields[0] =~ m/^subordinated loans|^loans/i) && do {
#          $subloans = $resfields[$#resfields];
#					last SWITCH;
#				};

#				($resfields[0] =~ m/^long term ins funds/i) && do {
#          $longinsfunds = $resfields[$#resfields];
#					last SWITCH;
#				};

#				($resfields[0] =~ m/^other ins funds/i) && do {
#          $otherinsfunds = $resfields[$#resfields];
#					last SWITCH;
#				};

#				($resfields[0] =~ m/^prefs, minorities/i) && do {
#          $prefs = $resfields[$#resfields];
#					last SWITCH;
#				};

#				($resfields[0] =~ m/^ord cap, reserves/i) && do {
#          $ordcapital = $resfields[$#resfields];
#					last SWITCH;
#				};

#				($resfields[0] =~ m/^mkt capitalisation/i) && do {
#          $cap = $resfields[$#resfields];
#					last SWITCH;
#				};

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

        printtofile( $logfile, "$hsid  $comp: Unknown data: $resfields[0] \n", $append);
				$nodata = 1;
				last SWITCH;
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
  $query = "SELECT hsid FROM current where EPIC like 'CTO'";
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
