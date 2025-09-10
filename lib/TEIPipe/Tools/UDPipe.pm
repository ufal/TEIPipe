package TEIPipe::Tools::UDPipe;

use Moose;
extends 'TEIPipe::Tool';

use strict;
use warnings;
use utf8;
use Getopt::Long;


sub BUILD {
    my ($self) = @_;
    $self->{input_type} //= {
        input => 1
    };
    $self->{result_type} //= {
        sentence => 1,
        token => 1,
        lemma => 1,
        pos => 1,
        tag => 1,
        features => 1,
        syntax => 1,
    };
}

sub help {
  print "UDPipe help\n";
}


sub parse_args {
  #my @args = @_;
  #my $opts


}

1;