package TEIPipe::Formats::XML;

# ABSTRACT: TEIPipe::Formats::XML - basic manipulation with XML files

use strict;
use warnings;

use XML::LibXML;
use XML::LibXML::PrettyPrint;
use File::Basename 'dirname';


sub open_xml {
  my $file = shift;
  my $xml;
  local $/;
  open FILE, $file;
  binmode ( FILE, ":utf8" );
  my $rawxml = <FILE>;
  close FILE;

  if ((! defined($rawxml)) || $rawxml eq '' ) {
    print STDERR " -- empty file $file\n";
  } else {
    my $parser = XML::LibXML->new();
    my $doc = "";
    eval { $doc = $parser->load_xml(string => $rawxml); };
    if ( !$doc ) {
      print STDERR " -- invalid XML in $file\n";
      print "$@";

    } else {
      $xml = {raw => $rawxml, dom => $doc}
    }
  }
  return $xml
}

sub to_string {
  my $doc = shift;
  my $pp = XML::LibXML::PrettyPrint->new(
    indent_string => "   ",
    element => {
        inline   => [qw//], # note
        block    => [qw/person/],
        compact  => [qw/catDesc term label date edition title meeting idno orgName persName resp licence language sex forename surname measure head roleName/],
        preserves_whitespace => [qw/s seg note ref p desc name change/],
        }
    );
  $pp->pretty_print($doc);
  return $doc->toString();
}

sub save_to_file {
  my ($doc,$filename) = @_;
  my $dir = dirname($filename);
  File::Path::mkpath($dir) unless -d $dir;
  open FILE, ">$filename";
  binmode FILE;
  my $raw = to_string($doc);
  print FILE $raw;
  close FILE;
}

sub corpus_components {
  my $root_path = shift;
  my $xml = open_xml($root_path);
  my @components;
  for my $child ($xml->{dom}->documentElement()->childNodes()){
    next unless $child->nodeType == XML_ELEMENT_NODE;
    next unless $child->localName() eq 'include';
    push @components, $child->getAttribute('href');
  }
  return @components;
}

sub corpus_includes {
  my $root_path = shift;
  my $xml = open_xml($root_path);
  my @includes;
  for my $incl ($xml->{dom}->documentElement()->findnodes('//*[local-name() = "include"]')){
    push @includes, $incl->getAttribute('href');
  }
  return @includes;
}

sub tei_texts {
  my $xml = shift;
  my @texts;
  for my $child ($xml->documentElement()->childNodes()){
    next unless $child->nodeType == XML_ELEMENT_NODE;
    next unless $child->localName() eq 'text';
    push @texts, $child;
  }
  return @texts;
}

1;