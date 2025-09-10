package TEIPipe::Formats::JSONL;

# ABSTRACT: TEIPipe::Formats::JSONL - internal jsonl format

use strict;
use warnings;
use utf8;

sub new {
  my $this  = shift;
  my %opts = @_;
  my $path = $opts{path};
  my $class = ref($this) || $this;
  my $self = {
    pars => []
  };
  $self->{pars} = [open_jsonl($path)] if $path;

  bless $self, $class;

  return $self;
}

sub open_jsonl {
  my $file = shift;
  print STDERR "TODO: open jsonl not implemented\n";
  return ();
}

sub add_paragraph {
  my $self = shift;
  my $par = shift;
  push @{$self->{pars}}, $par;
  return $self;
}



1;