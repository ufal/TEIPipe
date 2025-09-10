package TEIPipe::Formats::TEI;

# ABSTRACT: TEIPipe::Formats::TEI - basic manipulation with TEI files

use strict;
use warnings;
use utf8;
use open ':utf8';
binmode STDIN, ":encoding(UTF-8)";
binmode STDOUT, ":encoding(UTF-8)";
binmode STDERR, ":encoding(UTF-8)";

use XML::LibXML;
use XML::LibXML::PrettyPrint;
use File::Basename 'dirname';


sub new {
  my $this  = shift;
  my %opts = @_;
  my $path = $opts{path};
  my $class = ref($this) || $this;
  my $self  = open_xml($path);
  $self->{process} = $opts{process} // [qw/ref/];
  bless $self, $class;

  return $self;
}

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
  my $self = shift;
  my $pp = XML::LibXML::PrettyPrint->new(
    indent_string => "   ",
    element => {
        inline   => [qw//], # note
        block    => [qw/person/],
        compact  => [qw/catDesc term label date edition title meeting idno orgName persName resp licence language sex forename surname measure head roleName/],
        preserves_whitespace => [qw/s seg note ref p desc name change/],
        }
    );
  $pp->pretty_print($self->{dom});
  return $self->{dom}->toString();
}

sub save_to_file {
  my $self = shift;
  my ($filename) = @_;
  my $dir = dirname($filename);
  File::Path::mkpath($dir) unless -d $dir;
  open FILE, ">$filename";
  binmode FILE;
  my $raw = $self->to_string();
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

sub language {
  my $element = shift;
  return unless ref($element) =~ m/LibXML::Element/;
  my $expr = 'string(ancestor-or-self::*[@*[local-name()="lang" and namespace-uri()="http://www.w3.org/XML/1998/namespace"]][1]'
              . '/@*[local-name()="lang" and namespace-uri()="http://www.w3.org/XML/1998/namespace"])';
  return $element->findvalue($expr)
}

sub config_process {
  my $self = shift;
  return $self->{process} // [];
}

=head2 paragraphs

Paragraphs object that needs to be annotated

  @paragraphs = $object->paragraphs()

=head3 Returns

=cut
sub paragraphs {
  my $self = shift;
  return $self->{dom}->documentElement()->findnodes('//*[local-name() = "text"]//*[local-name() = "seg"]');
}

1;