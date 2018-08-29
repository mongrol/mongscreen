# Download and parse company files from ftse.com

sub getftseprices{
  # Parameters
	my (@infotype) = @_;

  $ua->cookie_jar(HTTP::Cookies::Mozilla->new(
                   File     => "cookies.txt",
                   AutoSave => 1,
               ));

  # connect to database
  $dbh = DBI->connect('dbi:mysql:ftse:213.208.89.139:3306', "screen", "ftse");

  foreach $infotype ( @infotype )
    {
    $url = "http://www.ftse.com/objects/csv_to_table.jsp?"
			. "infoCode=$infotype"
			. "&theseFilters=&csvAll=&theseColumns=MiwxLDQsMTQsMTIsOa==&theseTitles=&tableTitle=FTSE%20100%20Index%20Constituents&p_encoded=1";
    print "$url \n" if $debug;
    for ( $i=0; (($i<5) and !$getok) ; $i++ ) {
			print "$infotype: attempt $i\n" if $debug;
		  #$res = $ua->request(HTTP::Request->new(GET =>$url), $opfile) ;
      $doc = get "$url";
    }
    print "---------";
    #print "$doc";
    $te = new HTML::TableExtract(depth => 0, count => 1 );
    $te->parse($doc);

    foreach $ts ($te->table_states)
      {
      print "Table found at ", join(',', $ts->coords), ":\n";
      print "-------------------\n";
      foreach $row ($ts->rows)
        {
        if (@$row[0]=~ /\s/)
          {
            next;
          }
          else
          {
          if (@$row[0])
            {
            $epic = @$row[0];
            $cap = @$row[6];
            $price = @$row[10];
            #$price =~ s/'//g;  # remove any quote cos they hump the insert query
            print "$epic : $price : $cap\n";
            $query = "UPDATE current SET
                            Price = '$price',
                            Cap = '$cap'
                            WHERE EPIC='$epic'";
            $sth = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
            $sth->execute || die "execute: $query: $DBI::errstr";
            $sth->finish();
            next;
            }
          }
          print "", join(',', @$row), "\n";
        }
      }}
}

sub getftseinfo {

  # Parameters
	my (@infotype) = @_;

  $ua->cookie_jar(HTTP::Cookies::Mozilla->new(
                   File     => "cookies.txt",
                   AutoSave => 1,
               ));

  # connect to database
  $dbh = DBI->connect('dbi:mysql:ftse:213.208.89.139:3306', "screen", "ftse");

  foreach $infotype ( @infotype ) {

    $url = "http://www.ftse.com/objects/csv_to_table.jsp?"
			. "infoCode=$infotype"
			. "&theseFilters=&csvAll=&theseColumns=MiwxNywzLDQsNw==&theseTitles=&tableTitle=FTSE%20100%20Index%20Constituents&p_encoded=1";

		print "$url \n" if $debug;

    # Make up to five attempts to get the data
    for ( $i=0; (($i<5) and !$getok) ; $i++ ) {
			print "$infotype: attempt $i\n" if $debug;
		  #$res = $ua->request(HTTP::Request->new(GET =>$url), $opfile) ;
      $doc = get "$url";
    }
    
    #print "$doc";
    $te = new HTML::TableExtract(depth => 0, count => 1);
    $te->parse($doc);

    #foreach $ts ($te->table_states) {
    #print "Table (", join(',', $ts->coords), "):\n";
    #foreach $row ($ts->rows) {
    #   print join(',', @$row), "\n";
    #}
    #}


    foreach $ts ($te->table_states) {
      print "Table found at ", join(',', $ts->coords), ":\n";
      print "-------------------\n";

      foreach $row ($ts->rows) {
        if (@$row[0]=~ /\s/)
          {
            next;
            }
          else
          {
            if (@$row[0])
                {
                $epic = @$row[0];
                $name = @$row[4];
                $name =~ s/'//g;  # remove any quote cos they hump the insert query
                print "$epic : $name\n";
                $query = "INSERT INTO current (EPIC, Name) VALUES ('$epic','$name')";
                $sth = $dbh->prepare($query) || die "prepare: $query: $DBI::errstr";
                $sth->execute; # || die "execute: $query: $DBI::errstr";
                $sth->finish();
                next;
                }
          }
          print "", join(',', @$row), "\n";
        }
      }
   }
$dbh->disconnect();
}

