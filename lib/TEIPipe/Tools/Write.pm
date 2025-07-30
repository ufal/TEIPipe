package TEIPipe::Tools::Write;

use strict;
use warnings;
use Getopt::Long;
use File::Spec;
use File::Path;
use File::Copy;
use File::Basename 'dirname';

my %type = map { $_ => 1 } qw/output/;

sub type {
  shift;
  my $type = shift;
  return !!$type{$type} if $type;
  return keys %type;
}

sub help {
  print "Write help\n";
}

sub new  {
  my $this  = shift;
  my $local_opts = shift;
  my %opts = @_;
  my $class = ref($this) || $this;
  my $self  = {
    config => {
      local => $local_opts,
      global => $opts{global}
    },
    base_dir => undef,
    mode => 'stdout',
  };
  bless $self, $class;
  if ($local_opts->{mode} eq 'file') {
    $self->{base_dir} = $local_opts->{output};
    $self->{mode} = $local_opts->{mode};
  }
  return $self;
}

sub run {
  my $self = shift;
  my $task = shift;
  if($self->{mode} eq 'file'){
    my $path = File::Spec->catfile($self->{base_dir}, $task->relative_input_path);
    my $dir = dirname($path);
    File::Path::mkpath($dir) unless -d $dir;
    if($self->{to_modify}){
      print STDOUT "INFO: saving to $path\n";
      TEIPipe::Formats::TEI::save_to_file($task->{xml}, $path);
    } else {
      print STDOUT "INFO: copying to $path\n";
      copy($task->absolute_input_path,$path)
    }
  } else {
    print STDOUT TEIPipe::Formats::TEI::to_string($task->{xml});
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