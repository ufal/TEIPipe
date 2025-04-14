package TEIPipe::Tools::Read;

use strict;
use warnings;
use Getopt::Long qw/GetOptionsFromArray/;
use Data::Dumper;




sub new  {

}


sub help {
  print "Read help\n";
}


sub parse_args {
  my @ARGV = @_;
  my (@input, %opts);
  my @modes = qw/dir files corpus/;
  GetOptionsFromArray (
    \@ARGV,
    \%opts,
    @modes,
    '<>' => sub {push @input, shift;}
  );
  if((grep {$_} @opts{@modes}) != 1){
    die "ERROR: One of mutually exclusive param has to be set: (--".join(" | --",@modes),")\n";
  }
  my ($mode) = grep {$opts{$_}} @modes;
  if($mode eq 'dir' or $mode eq 'corpus'){
    die "ERROR: One $mode path needs to be set\n" unless @input == 1;
  } else {
    die "ERROR: Atleast one $mode path needs to be set\n" unless scalar(@input) > 0;
  }
  return {
    mode => $mode,
    input => [@input]
  };
}

1;