#!/usr/bin/env perl
#
# The build-system is Copyright (C) 2017 Alexander Kuleshov <kuleshovmail@gmail.com>,
#
# Github: https://github.com/0xAX/kernel-dev/tree/master/kernel-testing

use strict;

use Cwd;
use Data::Dumper;

sub provision_bootlader {
    my $config = shift;
    my $mount_points = shift;
    my %mount_points = %{$mount_points};
    my $root = shift;
    my $bootable_partition = "";
    my $device = "";
    my $curdir = `pwd`;
    my $new_root = "";

    chomp($curdir);

    # search boot partition
    foreach (@{$config->{partitions}}) {
        if (defined($_->{bootable})) {
            if ($_->{bootable} eq "true") {
                $bootable_partition = $_;
            }
            last;
        }
    }

    # exit early if we have no boot partition
    if (ref($bootable_partition) ne "HASH" && $bootable_partition eq "") {
        print STDERR "[error] bootable partition is not found\n";
        return -1;
    }

    print "[info] install bootloader to $root image\n";
    $device = $mount_points->{$bootable_partition->{mountPoint}};

    # switch to new root
    if ($bootable_partition->{mountPoint} eq "/boot") {
        $new_root = dirname($root . $bootable_partition->{mountPoint});
    } else {
        $new_root = $root . $bootable_partition->{mountPoint};
    }   
    chdir($new_root);

    # mount needed dirs to install bootloader
    my $dir = getcwd;
    `mkdir -p proc && mount -t proc none $dir/proc`;
    `mkdir -p dev && mount -o bind /dev $dir/dev`;
    `mkdir -p sys && mount -t sysfs sys $dir/sys`;

    # switch to new root
    if (fork()) {
        wait;
    } else {
        chroot($dir);
        chdir("/");

        #
        # TODO provision bootloader from docker image
        #
        
        exit 0;
    }

    # umount everything
    `umount $dir/proc`;
    `umount $dir/dev`;
    `umount $dir/sys`;

    # chroot /mnt/ /bin/bash
    chdir($curdir);

    return 0;
}

1;
