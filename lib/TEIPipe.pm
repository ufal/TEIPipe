package TEIPipe;

# ABSTRACT: TEIPipe base class

use strict;
use warnings;
use TEIPipe::Tools;

sub new {
  my $this  = shift;
  my $class = ref($this) || $this;
  my $opts = shift;
  my $self  = {};
  bless $self, $class;
  
  return $self;
}

sub run {
  my $self = shift;
}


1;