package TEIPipe::Data;

use strict;
use warnings;
use utf8;

sub new {
  my $this  = shift;
  my %opts = @_;
  my $class = ref($this) || $this;
  my $self  = {
    %opts
  };

  bless $self, $class;
  return $self;
}


sub relative_input_path {
  return shift->{task}->{relative_input_path};
}

sub absolute_input_path {
  return shift->{task}->{absolute_input_path};
}

1;