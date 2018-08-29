sub getyahprices{

    $dbh = DBI->connect('dbi:mysql:ftse:213.208.89.139:3306', "screen", "ftse");
    $query = "SELECT EPIC FROM current";
    $sth = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
    $sth->execute || die "execute: $query: $DBI::errstr";

    while ($epic = $sth->fetchrow_array())
      {
      &getquotes ("http://uk.finance.yahoo.com/d/quotes.csv?s=$epic&f=sl1ba&e=.csv");
      print "$epic Done\n";
      }
$dbh->disconnect();
}

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

sub getanal{

    $dbh = DBI->connect('dbi:mysql:ftse:213.208.89.139:3306', "screen", "ftse");
    $query = "SELECT EPIC FROM current";
    $sth = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
    $sth->execute || die "execute: $query: $DBI::errstr";
    $logfile = "log.txt";
    $append = TRUE;
    while ($epic = $sth->fetchrow_array())
      {
        my ($consensus1,$consensus2);
        print "-------------------------------Doing $epic \n";
        #fetch fundie profile
        $ecode = substr( $epic, 0, 1);
        # Extract Analyst data
        $url = "http://uk.biz.yahoo.com/z/$ecode/$epic.l.html";
        print "$url\n";
        $doc = get($url);
        if ($doc =~ /may no longer exist/)
          {
          print "$epic: No Yahoo Analyst page at $url\n";
          next;
          }
        $te = new HTML::TableExtract();
        $te->parse($doc);
        foreach $ts ($te->table_states){
        foreach $row ($ts->rows) {
          if (@$row[0] =~ /Forecast Year 1|EPS 1/)
            {
            $consensus1 = @$row[2];
            print "Consensus1 is $consensus1\n";
            }
          if (@$row[0] =~ /Forecast Year 2|EPS 2/)
            {
            $consensus2 = @$row[2];
            print "Consensus2 is $consensus2\n";
            }
          }
        }

        $query = "UPDATE current SET
            ConsensusEPS1 = '$consensus1',
            ConsensusEPS2 = '$consensus2'
            WHERE EPIC='$epic'";
        print "$epic Done\n";
        $stu = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
        $stu->execute || die "execute: $query: $DBI::errstr";
        $stu->finish();
        }
$sth->finish();
$dbh->disconnect();
}

