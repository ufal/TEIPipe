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

use Data::Dumper;

sub new {
  my $this  = shift;
  my $class = ref($this) || $this;
  my $opts = shift;
  my $self  = {
    input => undef,
    steps => [],

  };
  my %steps_seen = ();
  for my $step_opt (@{$opts->{steps}}) {
    die "module is not set" unless exists $step_opt->{module};
    my $module = $step_opt->{module};
    TEIPipe::Tools::load_tool($module);
    my $step = $module->new($step_opt->{setting}, seen => \%steps_seen, global => $opts->{global}//{});
    for my $type ($step->type()) {
      die "ERROR: only first command is allowed to be an input type\n" if $type eq 'input' && @{$self->{steps}} > 0;
      die "ERROR: first command has to be am input type\n" if $type ne 'input' && @{$self->{steps}} == 0;
      $steps_seen{$type} = 0 unless exists $steps_seen{$type};
      $steps_seen{$type} += 1;
    }
    push @{$self->{steps}}, $step;
  }
  $self->{input} = shift @{$self->{steps}};
  bless $self, $class;

  #print STDERR Dumper($self);
  return $self;
}

sub run {
  my $self = shift;
  while(my $input = $self->{input}->next()) {
    $input->{to_modify} = TEIPipe::XML::tei_texts($input->{xml});
    print "INFO: processing ",$input->{relative_path},"\n";
    my $step_result = $input;
    for my $step (@{$self->{steps}}) {
      next if !$input->{to_modify} && $step->type('modify');
      $step->{to_modify} = $input->{to_modify};
      $step_result = $step->run($step_result);
    }

  }
}


1;