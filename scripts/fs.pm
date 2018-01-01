#!/usr/bin/env perl
#
# The build-system is Copyright (C) 2017 Alexander Kuleshov <kuleshovmail@gmail.com>,
#
# Github: https://github.com/0xAX/kernel-dev/tree/master/kernel-testing

use Data::Dumper;

sub make_fs {
    my $config = shift;
    my $image = shift;
    my $idx = 0;
    my %mount_points;

    my $disk_info = `sfdisk -d $image`;
    my @partitions = ($disk_info =~ /start\=\s+([0-9]*),/g);

    foreach (@partitions) {
        my $fs = $config->{partitions}[$idx]->{fs}[0];
        my $makefs_util = $fs->{format_util};
        my $makefs_opts = $fs->{format_util_opts};
        my $mount_point = $config->{partitions}[$idx]->{mountPoint};
        my $loop_device = `losetup -f`;
        $loop_device =~ tr/\r\n//d;
        my $ret = system("losetup", $loop_device, $image, "-o", $_);

        if ($ret != 0) {
            print STDERR "[error] during losetup $Loop_device $image -o $_\n";
            print STDERR "Do not forget delete already created loop devices\n";
            return -1;
        }

        print "[info] formating $mount_point to $fs->{name}\n";
        if (!defined($makefs_opts)) {
            $_ = `$makefs_util $loop_device >/dev/null 2>&1`;
        } else {
            $_ = `$makefs_util $makefs_opts $loop_device >/dev/null 2>&1`;
        }

        if ($? != 0) {
            print STDERR "[error] during formating of a partition\n";
            print STDERR "Try to execute manually:";
            if (!defined($makefs_opts)) {
                print STDERR "$makefs_util $loop_device";
            } else {
                print STDERR "$makefs_util $makefs_opts $loop_device";
            }
            return -1;
        }

        $mount_points{$mount_point} = $loop_device;
        $idx++;
    }

    return \%mount_points;
}

1;
