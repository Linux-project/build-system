#!/usr/bin/env perl
#
# The build-system is Copyright (C) 2017 Alexander Kuleshov <kuleshovmail@gmail.com>,
#
# Github: https://github.com/0xAX/kernel-dev/tree/master/kernel-testing

use Data::Dumper;

sub make_fs {
    $config = shift;
    $image = shift;

    my $disk_info = `sfdisk -d $image`;
    my @partitions = ($disk_info =~ /start\=\s+([0-9]*),/g);
}

1;
