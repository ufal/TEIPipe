package TEIPipe::Converter::TEIpar2JSON;

# ABSTRACT: TEIPipe::Converter::TEIpar2JSON

use strict;
use warnings;
use utf8;

use TEIPipe::Formats::TEI;

sub convert {
  my $teiPar = shift;
  my %opts = @_;
  my %process = map {$_ => 1} @{$opts{process} // []};
  unless(ref($teiPar) =~ m/LibXML::Element/){
    print STDERR "ERROR: no input for ", __PACKAGE__," ",caller,"\n";
    return
  }

  # loop over childs (only one level of nesting !!!)
  my $items = [];
  my $plain_text = '';
  convert_childs($items,
                 \$plain_text,
                 $teiPar,
                 process => \%process);
  return {
    language => TEIPipe::Formats::TEI::language($teiPar) // undef,
    ref => $teiPar,
    text => $plain_text,
    items => $items,
  }

}

sub convert_childs {
  my $items = shift;
  my $plain_text = shift;
  my $element = shift;
  my %opts = @_;
  my $process = $opts{process} // {};

  for my $child ($element->childNodes()) {
    if (ref($child) =~ m/LibXML::Element/ && $process->{$child->nodeName}) {
      convert_childs($items, $plain_text, $child, %opts);
    } elsif ( ref($child) =~ m/LibXML::Text/) {
      my $text = $child->data;
      my ($sp_b,$txt,$sp_e) = $text =~ m/^(\s*)(.*?)(\s*)$/;
      for my $t ($sp_b,$txt,$sp_e) {
        next unless $t;
        my $item = {
          type => $t =~ m/^\s+$/ ? "space" : "text",
          text => $t,
          tei => {
            ref => $child,
            parent_ref => $element,
            parent_name => $element->nodeName,
          },
          char_start => length($$plain_text)
        };
        $$plain_text .= $t;
        $item->{char_end} = length($$plain_text);
        push @$items, $item;
      }
    } else {
      push @$items, {
          type => "unknown",
          tei => {
            parent_ref => $element,
            parent_name => $element->nodeName,
            ref => $child,
            name => $child->nodeName,
          },
          char_start => length($$plain_text),
          char_end => length($$plain_text),
        };
    }
  }
}

1;