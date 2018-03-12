#!/usr/bin/env perl
#
# The build-system is Copyright (C) 2017 Alexander Kuleshov <kuleshovmail@gmail.com>,
#
# Github: https://github.com/0xAX/build-system

use Data::Dumper;

sub umount_partitions {
    my $ret = '';
    my $partitions = shift;
    my %partitions = %{$partitions};
    my $root_device= $partitions{"/"};

    while (($k, $v) = each (%partitions)) {
        # we will umount root at the end
        if ($k eq "/") {
            next;
        }

        # no need to umount non-exists device
        $ret = `mount | grep $v`;
        if ($ret eq '') {
            next;
        }

        print "[info] umount $k binded to $v\n";
        $ret = system("umount", $v);
        if ($ret != 0) {
            print STDERR "[error] something going wrong during umount of $k binded to $v\n";
        }
    }

    # no need to umount non-exists device
    $ret = `mount | grep $root_device`;
    if ($ret eq '') {
        return;
    }

    print "[info] umount / binded to $root_device\n";
    $ret = system("umount", $root_device);
    if ($ret != 0) {
        print STDERR "[error] something going wrong during umount of / binded to $root_device\n";
    }
}

sub mount_partitions {
    my $config = shift;
    my $image = shift;
    my $partitions = shift;
    my %partitions = %{$partitions};
    my $root_device = $partitions{'/'};
    my $image_name = basename($image);
    my $root_dir = dirname($image) . "/$image_name-root";

    if (!defined($partitions{'/'})) {
        print STDERR "[error] no root partition found\n";
        return -1;
    }

    # umount all partitions related to build-system at the beginning
    umount_partitions($partitions);

    # create root directory
    mkdir($root_dir);

    # mount root directory
    foreach (@{$config->{partitions}}) {
        if ($_->{mountPoint} eq '/') {
            my $fs_type = $_->{fs}[0]->{name};

            print "[info] mount / partition to $root_device with $fs_type fs\n";
            my $ret = `mount -t $fs_type $root_device $root_dir >/dev/null 2>&1`;

            if ($? != 0) {
                print STDERR "[error] mount of $root_device to $root_dir failed\n";
                print STDERR "Try to execute mount -t $fs_type $root_device $root_dir manually\n";
                return -1;
            }

            last;
        }
    }

    # mount other directories
    foreach (@{$config->{partitions}}) {
        my $fs_type = $_->{fs}[0]->{name};
        my $device = $partitions{$_->{mountPoint}};

        if ($_->{mountPoint} eq '/') {
            next;
        }

        my $mount_point = $root_dir . $_->{mountPoint};
        mkdir($mount_point);

        print "[info] mount $_->{mountPoint} partition to $device with $fs_type fs\n";
        my $ret = `mount -t $fs_type $device $mount_point >/dev/null 2>&1`;

        if ($? != 0) {
            print STDERR "[error] mount of $device to $mount_point failed\n";
            print STDERR "Try to execute mount -t $fs_type $device $mount_point manually\n";
            return -1;
        }
    }

    return $root_dir;
}

1;
