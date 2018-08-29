# ======================================================================
#
# Perl Source File -- Created with SAPIEN Technologies PrimalSCRIPT(TM)
#
# NAME: <filename>
#
# AUTHOR: mongrol , wot?
# DATE  : 08/08/2002
#
# PURPOSE: Download Stock information
#
# ======================================================================
# Create a user agent object
#use strict;
use warnings;

use LWP::UserAgent;
use HTTP::Request::Common;
use IO::Handle;

# fetch EPIC code list from UK all companies inc inelegibles

#  my $url = 'http://www.ftse.com/scripts/ftse1c.pl';
#  my $ua = new LWP::UserAgent;

#  my $res = $ua->request(POST $url, [
#                    filename => 'indices/monlst.csv',
#                   csvset => 'comma',
#                   index => '']);

#  open ($file,'>','epicfull.html');
  # Check the outcome of the response
#  if ($res->is_success) {
#      select $file;
#      print $res->content;
#  } else {
#      print "Failed to get epic html\n";
#  }
#  close $file;

  #Strip html

  package HTMLStrip;
  use base "HTML::Parser";
  open ($file,'>','epicfull.txt');
  my $p = new HTMLStrip;
  sub text {
    my ($self, $text) = @_;
    print $file $text;
    }
  $p->parse_file("epicfull.html");

  close $file;

  use Text::CSV_XS;
  
  open ($file,'epicfull.txt');
  $csv = Text::CSV_XS->new();
  my $columns = $csv->getline($file);
  print $$columns;
  
  
  
