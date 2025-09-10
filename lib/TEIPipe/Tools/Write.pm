package TEIPipe::Tools::Write;

use Moose;
extends 'TEIPipe::Tool';

use strict;
use warnings;
use utf8;
use Getopt::Long;
use File::Spec;
use File::Path;
use File::Copy;
use File::Basename 'dirname';


sub BUILD {
  my ($self, $opts) = @_;
  $self->{input_type} //= {
      input => 1
  };
  $self->{result_type} //= {
      output => 1
  };
  $self->{config} = {
    local => $opts->{local},
    global => $opts->{global}
  };
  $self->{base_dir} = undef;
  $self->{mode} = 'stdout';

  if ($opts->{local}->{mode} eq 'file') {
    $self->{base_dir} = $opts->{local}->{output};
    $self->{mode} = $opts->{local}->{mode};
  }
}

sub help {
  print "Write help\n";
}


sub run {
  my $self = shift;
  my $task = shift;
print STDERR "DEBUG($self): task: $task\n";
  if($self->{mode} eq 'file'){
    my $path = File::Spec->catfile($self->{base_dir}, $task->relative_input_path);
    my $dir = dirname($path);
    File::Path::mkpath($dir) unless -d $dir;
    if($self->{to_modify}){
      print STDOUT "INFO: saving to $path\n";
      $task->save_to_file($path)
    } else {
      print STDOUT "INFO: copying to $path\n";
      copy($task->absolute_input_path,$path)
    }
  } else {
    print STDOUT $task->to_string();
  }
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