package TEIPipe::CLI;

use strict;
use warnings;
use utf8;
use Getopt::Long;
use Hash::Merge 'merge';

use File::Basename 'dirname';
use File::Spec ();
use File::ShareDir 'dist_dir';
use Data::Dumper;

use TEIPipe;
use TEIPipe::Tools;

my $local_shared_dir = File::Spec->catdir(dirname(__FILE__), File::Spec->updir, File::Spec->updir, File::Spec->updir, 'share');
my $shared_dir = eval { dist_dir(__PACKAGE__) };



# Assume installation
if (-d $local_shared_dir or !$shared_dir) {
  $shared_dir = $local_shared_dir;
}
sub shared_dir { $shared_dir }

sub run {
  my ($class,@args) = @_;
  print STDERR "ARGS: ",join(" ",@args),"\n";
  return help(@args) if @args && $args[0] eq 'help';
  my $setting = parse_args(@args);
  my $pipe = TEIPipe->new($setting);
  $pipe->run();
}

sub help {
  my (undef, @tools) = @_;
  if(@tools) {
    my %available_tools = map {$_ => 1} (TEIPipe::Tools::available_tools());
    while(my $tool = shift @tools){
      if(exists $available_tools{$tool}){
        TEIPipe::Tools::load_tool($tool);
        # call help for command/tool
        no strict 'refs';
        &{"TEIPipe::Tools::${tool}::help"}();
      } else {
        print "ERROR: unknown command '$tool'\n";
      }
    }
    return 1;
  }
  print "available commands:\n\t";
  print join("\n\t",TEIPipe::Tools::available_tools());
  print "\n";
  return 1;
}

sub parse_args {
  my @args = @_;
  my $setting = {
    global => {},
    steps => []
  };
  # split by tool and then parse
  my %available_tools = map {lc $_ => $_} (TEIPipe::Tools::available_tools());
  my @tasks;
  my $current_tool;
  while(my $arg = shift @args){
    if(exists $available_tools{lc $arg}){
      $current_tool = {};
      $current_tool->{name} = $available_tools{lc $arg};
      $current_tool->{setting} = 'local';
      $current_tool->{args} = [];
      push @tasks, $current_tool;
    } elsif (defined $current_tool) {
      push @{$current_tool->{args}}, $arg;
    } else {
      $current_tool = {};
      $current_tool->{setting} = 'global'; # shared setting among all tools (steps)
      $current_tool->{args} = [$arg];
      push @tasks, $current_tool;
    }
  }
  # print STDERR Dumper(@tasks);
  for my $t (@tasks){
    if($t->{setting} eq 'global'){
      print STDERR "parse global settings\n";
      $setting->{global} = parse_global_args(@{$t->{args}})
    } else {
      my $tool = $t->{name};
      TEIPipe::Tools::load_tool($tool);
      no strict 'refs';
      push @{$setting->{steps}}, { name => $tool, module => "TEIPipe::Tools::${tool}", setting => &{"TEIPipe::Tools::${tool}::parse_args"}(@{$t->{args}})};
    }
  }
  return $setting;
}

sub parse_global_args {
  my @args = @_;
  die "unknown params: ",join(" ", @args) if @args;
}

1;