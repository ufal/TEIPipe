package TEIPipe;

# ABSTRACT: TEIPipe - a pipeline for linguistic processig TEI files


=encoding utf8
=head1 NAME

TEIPipe - a pipeline for linguistic processig TEI files

=head1 SYNOPSIS

    use TEIPipe;
    my $pipe = TEIPipe->new();
    $pipe->run();

=head1 DESCRIPTION

This module concists of tools for linguistic annotations of TEI files.
Currently, they uses LINDAT services for the annotations, but the set
of annotations and tools is easily extensible.

=head1 AUTHOR

Matyáš Kopp <kopp@ufal.mff.cuni.cz>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

See L<https://dev.perl.org/licenses/>.

=cut


use strict;
use warnings;
use TEIPipe::Tools;

sub new {
  my $this  = shift;
  my $class = ref($this) || $this;
  #my $opts = shift;
  my $self  = {};
  bless $self, $class;

  return $self;
}

sub run {
  my $self = shift;
}


1;