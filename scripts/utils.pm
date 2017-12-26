#!/usr/bin/env perl
#
# The build-system is Copyright (C) 2017 Alexander Kuleshov <kuleshovmail@gmail.com>,
#
# Github: https://github.com/0xAX/kernel-dev/tree/master/kernel-testing

use strict;
use warnings "all";
use diagnostics;

use File::Path qw(make_path);

sub create_output_dir() {
    my $output_dir = shift;

    if (! -e $output_dir and ! -d $output_dir) {
        make_path($output_dir);
    }    
}

1;
