package TEIPipe::Tools;

use strict;
use warnings;
use utf8;

use Exporter 'import';
use File::Basename 'fileparse';
use File::Spec;

use TEIPipe::Tool;

sub available_tools {
  map {s/^TEIPipe::Tools:://;$_} find_tools('TEIPipe::Tools');
}

sub class_to_path { join '.', join('/', split /::|'/, shift), 'pm' }

sub load_tool {
  my ($tool) = @_;
print STDERR "LOADING $tool\n";
  my $class = "TEIPipe::Tools::$tool";
  no strict 'refs'; # allow running string as package name
  # Check module name
  return if !$class || $class !~ /^\w(?:[\w:']*\w)?$/;

  # Loaded
  return 1 if $class->can('new') || eval {
    my $file = class_to_path($class);
    require $file;
    1;
  };

  # Exists
  return if $@ =~ /^Can't locate \Q@{[class_to_path $class]}\E in \@INC/;

  # Real error
  die $@;
}

sub find_tools {
  my ($ns) = @_;

  my %modules;
  for my $directory (@INC) {
    next unless -d (my $path = File::Spec->catdir($directory, split(/::|'/, $ns)));

    # List "*.pm" files in directory
    opendir(my $dir, $path);
    for my $file (grep /\.pm$/, readdir $dir) {
      next if -d File::Spec->catfile(File::Spec->splitdir($path), $file);
      $modules{"${ns}::" . fileparse $file, qr/\.pm/}++;
    }
  }

  return keys %modules;
}


1;