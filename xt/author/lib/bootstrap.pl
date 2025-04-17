use warnings;
use strict;
use File::Spec;
use File::Find;
use File::Slurp;

use open qw(:std :utf8);
use utf8;
use XML::LibXML qw(:libxml);
use XML::CanonicalizeXML;



my $base_dir = abs_path( File::Spec->catdir( dirname(__FILE__), File::Spec->updir ) );

my $tei_xpath=
'<XPath xmlns:tei="http://www.tei-c.org/ns/1.0">
(//. | //@* | //namespace::*)[ancestor-or-self::tei:TEI]
</XPath>';


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


sub files_equal {
  my ($file1, $file2) = @_;
  return read_file($file1) eq read_file($file2);
}

sub xml_equal {
  my ($file1, $file2) = @_;
  return 1 if files_equal($file1, $file2);

  my $parser = XML::LibXML->new();

  my $doc1 = $parser->parse_file($file1);
  my $doc2 = $parser->parse_file($file2);

  my $canon1 = XML::CanonicalizeXML::canonicalize($doc1->documentElement, $tei_xpath, 'tei', 0, 0);
  my $canon2 = XML::CanonicalizeXML::canonicalize($doc2->documentElement, $tei_xpath, 'tei', 0, 0);

  # removing empty lines, which has been placed instead of comments
  $canon1 =~ s/^\s*\n//gm;
  $canon2 =~ s/^\s*\n//gm;

  return $canon1 eq $canon2;
}

sub find_xml_files {
  my ($base_dir) = @_;
  my %files;

  find(
    sub {
      return unless -f $_;
      return unless /\.xml$/i;
      #return if /taxonomy/i;
      #return if /listPerson/i;
      #return if /listOrg/i;
      my $rel_path = File::Spec->abs2rel($File::Find::name, $base_dir);
      $files{$rel_path} = $File::Find::name;
    },
    $base_dir
  );

  return %files;
}

sub compare_xml_dirs {
  my ($dir1, $dir2) = (shift, shift);
  my %opts = @_;
  my %files1;
  if($opts{expected_files}) {
    %files1 = map {File::Spec->abs2rel($_,$dir1) => $_} @{$opts{expected_files}};
  } else {
    %files1 = find_xml_files($dir1);
  }
  my %files2 = find_xml_files($dir2);

  my %all_paths = map { $_ => 1 } (keys %files1, keys %files2);

  foreach my $rel_path (sort keys %all_paths) {
    my $file1 = $files1{$rel_path};
    my $file2 = $files2{$rel_path};

    if (!$file1 || !$file2) {
      fail("File $rel_path exists in only one folder");
      next;
    }

    ok(xml_equal($file1, $file2), "Compare: $rel_path");
  }
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