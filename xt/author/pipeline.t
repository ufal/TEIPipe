#!/usr/bin/env perl
use Test::Most;
use File::Spec;
use File::Basename 'dirname';
use Cwd 'abs_path';
use lib File::Spec->rel2abs( File::Spec->catdir( dirname(__FILE__), 'lib' ) );
use lib abs_path( File::Spec->catdir( dirname(__FILE__), File::Spec->updir, File::Spec->updir, 'lib' ) );

use File::Temp;

use TEIPipe::CLI;
use TEIPipe::Tools;

BEGIN {
  require 'bootstrap.pl';
}


subtest invalid_pipeline => sub {
    dies_ok {TEIPipe::CLI->run('unknown')} 'calling unknown command';
    dies_ok {TEIPipe::CLI->run('unknown', '--dir', 'a')} 'calling unknown command';
    dies_ok {TEIPipe::CLI->run('write','result-dir')} 'calling write without reading input';
};



done_testing();