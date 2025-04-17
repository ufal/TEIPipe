package TEIPipe::Common;

# ABSTRACT: TEIPipe::Common - common functions

use strict;
use warnings;
use File::Spec;
use List::Util qw(min);
use List::MoreUtils qw(all);

sub deepest_common_folder {
  my @paths = @_;
  return '' unless @paths;

  my @split_paths = map { [ File::Spec->splitdir($_) ] } @paths;

  my $min_length = min(map { scalar @$_ } @split_paths);
  my @common;

  for my $i (0 .. $min_length - 1) {
    my $dir = $split_paths[0][$i];
    if (all { $_->[$i] eq $dir } @split_paths) {
      push @common, $dir;
    } else {
      last;
    }
  }

  return File::Spec->catdir(@common);
}

1;