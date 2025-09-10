package TEIPipe::Tools::NameTag;

use Moose;
extends 'TEIPipe::Tool';

use strict;
use warnings;
use utf8;





sub BUILD {
    my ($self) = @_;
    $self->{input_type} //= {
        sentence => 1,
        token => 1,
    };
    $self->{result_type} //= {
        NER => 1,
    };
}

1;