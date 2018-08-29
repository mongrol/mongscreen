package HTMLStrip;
  use base "HTML::Parser";

  sub text {
    my ($self, $text) = @_;
    print $text;
    }

  my $p = new HTMLStrip;

  $p->parse_file("epicfull.html");
  




