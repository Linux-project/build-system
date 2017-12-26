#!/usr/bin/env perl
#
# The build-system is Copyright (C) 2017 Alexander Kuleshov <kuleshovmail@gmail.com>,
#
# Github: https://github.com/0xAX/kernel-dev/tree/master/kernel-testing

use strict;
use warnings "all";
use diagnostics;

use File::Path qw(make_path);

sub create_dir_if_not_exists() {
    my $dir = shift;

    if (! -e $dir and ! -d $dir) {
        make_path($dir);
    }    
}

1;
