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
use utf8;
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
    my $step = $module->new(local => $step_opt->{setting}, seen => \%steps_seen, global => $opts->{global}//{});
print STDERR "STEP: $step\n";
    for my $p ($step->prereq_types) {
      die "missing prerequisity of type $p\n" unless exists $steps_seen{$p};
    }

    for my $type ($step->result_types) {
      die "ERROR: only first command is allowed to be an input type\n" if $type eq 'input' && @{$self->{steps}} > 0;
      die "ERROR: first command has to be an input type\n" if $type ne 'input' && not($self->{input});
      $steps_seen{$type} = 0 unless exists $steps_seen{$type};
      $steps_seen{$type} += 1;
    }
    if($self->{input}){
      push @{$self->{steps}}, $step;
    } else {
      $self->{input} = $step
    }
  }
  bless $self, $class;

  #print STDERR Dumper($self);
  return $self;
}

sub run {
  my $self = shift;
  while(my $input = $self->{input}->next()) {
    ##$input->{to_modify} = TEIPipe::Formats::TEI::tei_texts($input->{xml});
    print "INFO: processing ",$input->relative_input_path,"\n";
    my $step_result = $input;
    for my $step (@{$self->{steps}}) {
      $step_result = $step->run($step_result);
    }

  }
}


1;