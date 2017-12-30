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

sub delete_loop_devices() {
    my $image = basename(shift);
    my $loop_devices = `losetup`;

    # remove first line of losetup output
    $loop_devices =~ s/^(?:.*\n){1}//;
    my @loop_devices = split /\n/, $loop_devices;

    foreach (@loop_devices) {
        my @fields = split /\s+/, $_;
        my $loop_device = $fields[0];
        my $binded_device = basename($fields[5]);

        if ($binded_device eq $image) {
            system("losetup", "-d", $loop_device);
        }
    }
}

1;
