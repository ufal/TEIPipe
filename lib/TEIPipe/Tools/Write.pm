package TEIPipe::Tools::Write;

use strict;
use warnings;
use Getopt::Long;



sub help {
  print "Write help\n";
}



sub parse_args {
  my @dir = @_;
  if(@dir > 1) {
    shift @dir;
    die "ERROR: Unknown options ".join(" ",@dir)."\n"
  }
  my $mode = @dir == 1 ? 'file' : 'stdout';
  return {
    mode => $mode,
    output => $dir[0]
  };
}

1;