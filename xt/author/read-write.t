#!/usr/bin/env perl
use Test::Most;
use File::Spec;
use File::Basename 'dirname';
use Cwd 'abs_path';
use lib File::Spec->rel2abs( File::Spec->catdir( dirname(__FILE__), 'lib' ) );
use lib abs_path( File::Spec->catdir( dirname(__FILE__), File::Spec->updir, File::Spec->updir, 'lib' ) );

use TEIPipe::CLI;
use TEIPipe::Tools::Read;
use TEIPipe::Tools::Write;

BEGIN {
  require 'bootstrap.pl';
}


subtest read_args_valid => sub {
  for my $dir (corpora_folders()){
    lives_ok {TEIPipe::Tools::Read::parse_args('--dir', $dir)} 'read folder';  
    lives_ok {TEIPipe::CLI::parse_args('read', '--dir', $dir)} 'read folder';  
  }
  for my $corpus (map {corpus_root_path($_)} corpora_names()){
    lives_ok {TEIPipe::Tools::Read::parse_args('--corpus', $corpus)} 'read corpus';  
    lives_ok {TEIPipe::CLI::parse_args('read', '--corpus', $corpus)} 'read corpus';  
  }
  for my $corpus (map {corpus_root_path($_)} corpora_names()){
    my @files = corpus_components($corpus);
    lives_ok {TEIPipe::Tools::Read::parse_args('--files', @files)} 'read list of files';  
    lives_ok {TEIPipe::CLI::parse_args('read', '--files', @files)} 'read list of files';  
  }
};

subtest read_args_invalid => sub {
  throws_ok { TEIPipe::Tools::Read::parse_args() } qr/error/i, 'no input fails';
  throws_ok { TEIPipe::Tools::Read::parse_args("--corpus", "--dir") } qr/error/i, 'not mutually esclusive params fails';
  throws_ok { TEIPipe::Tools::Read::parse_args("--corpus", "--files") } qr/error/i, 'not mutually esclusive params fails';
  throws_ok { TEIPipe::Tools::Read::parse_args("--corpus") } qr/error/i, 'no input fails';
  my @corpora = (map {corpus_root_path($_)} corpora_names());
  throws_ok { TEIPipe::Tools::Read::parse_args("--corpus",@corpora) } qr/error/i, 'not single corpus fails';
};

subtest write_args_valid => sub {
  for my $dir (corpora_folders()) {
    lives_ok {TEIPipe::Tools::Write::parse_args("$dir-result")} 'write to folder';  
    lives_ok {TEIPipe::CLI::parse_args('write',"$dir-result")} 'write to folder';  
    lives_ok {TEIPipe::Tools::Write::parse_args()} 'write to stdout';  
    lives_ok {TEIPipe::CLI::parse_args('write')} 'write to strdout';  
  }
};

subtest write_args_invalid => sub {
  my @outdirs = (map {"$_-result"} corpora_folders());
  throws_ok { TEIPipe::Tools::Write::parse_args(@outdirs) } qr/error/i, 'not a single output folder fails';
};

subtest read_write_args_valid => sub {
  for my $dir (corpora_folders()) {
    lives_ok {TEIPipe::CLI::parse_args('read', '--dir', $dir, 'write', "$dir-result")} 'read folder';  
  }
};


subtest simple_run => sub {
  for my $dir (corpora_folders()) {
    lives_ok {TEIPipe::CLI->run('read', '--dir', $dir, 'write', "$dir-result")} 'read folder and write output';  
    ok(-d "$dir-result", 'output directory exists');
  }
};


done_testing();