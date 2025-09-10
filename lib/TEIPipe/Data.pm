package TEIPipe::Data;

use strict;
use warnings;
use utf8;

use Data::Dumper;
$Data::Dumper::Useqq = 0;
binmode STDOUT, ":encoding(UTF-8)";
binmode STDERR, ":encoding(UTF-8)";

use TEIPipe::Converter::TEIpar2JSON;
use TEIPipe::Formats::JSONL;
sub new {
  my $this  = shift;
  my %opts = @_;
  my $class = ref($this) || $this;
  my $self  = {
    %opts
  };

  bless $self, $class;
  return unless $self->load_to_internal_format();
  return $self;
}


sub relative_input_path {
  return shift->{task}->{relative_input_path};
}

sub absolute_input_path {
  return shift->{task}->{absolute_input_path};
}

sub load_to_internal_format {
  my $self = shift;
  if(exists $self->{tei}){
    print STDERR "TODO: load to jsonl\n";
    $self->{jsonl} = TEIPipe::Formats::JSONL->new();
    for my $p ($self->{tei}->paragraphs){
      my $json = TEIPipe::Converter::TEIpar2JSON::convert($p, process => $self->{tei}->config_process());
      if($json) {
        $self->{jsonl}->add_paragraph($json);
      } else {
        print STDERR "ERROR: unable to load paragraph to internal form\n";
      }
    }

  } else {
    die "unable to load to internal format"; # temporary solution
  }
  print STDERR Dumper($self->{jsonl});
  return 1; # succesfully loaded
}


1;