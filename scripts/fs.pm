#!/usr/bin/env perl
#
# The build-system is Copyright (C) 2017 Alexander Kuleshov <kuleshovmail@gmail.com>,
#
# Github: https://github.com/0xAX/kernel-dev/tree/master/kernel-testing

use Data::Dumper;

sub make_fs {
    my $config = shift;
    my $image = shift;

    my $disk_info = `sfdisk -d $image`;
    my @partitions = ($disk_info =~ /start\=\s+([0-9]*),/g);

    foreach (@partitions) {
        my $loop_device = `losetup -f`;
        $loop_device =~ tr/\r\n//d;
        my $ret = system("losetup", $loop_device, $image, "-o", $_);

        if ($ret != 0) {
            print STDERR "[error] during losetup $Loop_device $image -o $_\n";
            print STDERR "Do not forget delete already created loop devices\n";
            return -1;
        }
    }

    return 1;
}

1;
