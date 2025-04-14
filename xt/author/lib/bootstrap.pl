use warnings;
use strict;
use File::Spec;
use open qw(:std :utf8);
use utf8;
use XML::LibXML qw(:libxml);


my $base_dir = abs_path( File::Spec->catdir( dirname(__FILE__), File::Spec->updir ) );

sub corpora_folders {
  my $n = shift // '*';
  return glob("$base_dir/corpora/$n");
}

sub corpora_names {
  my $n = shift // '*';
  return map {s@^.*/@@;$_} corpora_folders($n);
}

sub corpora_roots {
  my $n = shift // '*';
  return map {"$_.xml"} corpora_names($n);
}

sub corpus_root_path {
  my $name = shift;
  return glob("$base_dir/corpora/$name/$name.xml");
}

sub corpus_components {
  my $root_path = shift;
  my $corpus_root_folder = dirname($root_path);
  my $xml = open_xml($root_path);
  my @components;
  for my $child ($xml->{dom}->documentElement()->childNodes()){
    next unless $child->nodeType == XML_ELEMENT_NODE;
    next unless $child->localName() eq 'include';
    push @components, $child->getAttribute('href');
  }
  return map {File::Spec->catfile($corpus_root_folder,$_)} @components;

}






sub open_xml {
  my $file = shift;
  my $log = shift // [];
  my %vars = @_;
  my $xml;
  local $/;
  open FILE, $file;
  binmode ( FILE, ":utf8" );
  my $rawxml = <FILE>;
  close FILE;

  if ((! defined($rawxml)) || $rawxml eq '' ) {
    print " -- empty file $file\n";
  } else {
    my $parser = XML::LibXML->new();
    my $doc = "";
    eval { $doc = $parser->load_xml(string => $rawxml); };
    if ( !$doc ) {
      print " -- invalid XML in $file\n";
      print "$@";

    } else {
      $xml = {raw => $rawxml, dom => $doc}
    }
  }
  return $xml
}



1;