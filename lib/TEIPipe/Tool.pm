package TEIPipe::Tool;

use strict;
use warnings;
use utf8;

use Moose;

use Data::Dumper;

has 'input_type' => (
    is       => 'ro',
    isa      => 'HashRef[Str]',
);

has 'result_type' => (
    is       => 'ro',
    isa      => 'HashRef[Str]',
);


sub prereq_types {
  my ($self) = @_;
  return keys %{$self->input_type};
}

sub result_types {
  my ($self) = @_;
  return keys %{$self->result_type};
}

1;