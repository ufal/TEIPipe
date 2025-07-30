package TEIPipe::Tools::Read;

use strict;
use warnings;
use Getopt::Long qw/GetOptionsFromArray/;
use File::Basename 'dirname';
use File::Spec;
use File::Find;

use TEIPipe::Formats::TEI;
use TEIPipe::Common;
use TEIPipe::Data;

use Data::Dumper;


my %type = map { $_ => 1 } qw/input/;

sub type {
  shift;
  my $type = shift;
  return !!$type{$type} if $type;
  return keys %type;
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
    task_list => [],
    task_position => 0
  };

  bless $self, $class;
  $self->add_files($local_opts->{mode},@{$local_opts->{input}});
  $self->set_base_dir($local_opts->{mode},@{$local_opts->{input}});
  $_->{relative_input_path} = File::Spec->abs2rel($_->{absolute_input_path}, $self->{base_dir}) for (@{$self->{task_list}});
  return $self;
}

sub get_task_cnt {
  my $self = shift;
  return scalar @{$self->{task_list}};
}

sub next {
  my $self = shift;
  return if $self->{task_position} >= @{$self->{task_list}};
  my %task = %{$self->{task_list}->[$self->{task_position}]};
  $self->{task_position} += 1;
  my $xml = TEIPipe::Formats::TEI::open_xml($task{absolute_input_path});
  die "ERROR: invalid input file\n" unless $xml;
  return TEIPipe::Data->new(
    task => {%task},
    text => $xml->{raw},
    xml => $xml->{dom},
  )
}

sub set_base_dir {
  my $self = shift;
  my $mode = shift;
  my $path = shift;
  if($mode eq 'files'){
    $self->{base_dir} = TEIPipe::Common::deepest_common_folder(map {$_->{absolute_input_path}} @{$self->{task_list}})
  } elsif ($mode eq 'corpus') {
    $self->{base_dir} = dirname($path);
  } else {
    $self->{base_dir} = $path;
  }
}


sub add_files {
  my $self = shift;
  my $mode = shift;
  my ($input,@input) = @_;
  if($mode eq 'files'){
    $self->add_file($_) for ($input,@input);
  } elsif ($mode eq 'corpus') {
    # read corpus root and get all component files
    my $corpus_root_folder = dirname($input);
    my @includes = TEIPipe::Formats::TEI::corpus_includes($input);
    $self->add_files('files', map {File::Spec->catfile($corpus_root_folder,$_)} @includes);
    $self->add_files('files',$input); # add also corpus file (which will be only copied)
  } elsif ($mode eq 'dir') {
    my @files = ();
    find(
      sub {
        return unless -f;
        push @files, $File::Find::name;
      },
      $input
    );
    $self->add_files('files', @files);
  } else {
    die "ERROR: unknown mode\n";
  }
}


sub add_file {
  my $self = shift;
  my $file = shift;
  push @{$self->{task_list}},{absolute_input_path => $file};
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