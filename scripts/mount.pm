#!/usr/bin/env perl
#
# The build-system is Copyright (C) 2017 Alexander Kuleshov <kuleshovmail@gmail.com>,
#
# Github: https://github.com/0xAX/kernel-dev/tree/master/kernel-testing

use Data::Dumper;

sub umount_partitions {
    my $root_dir = basename(shift);

    my $mounted_fs = `mount | grep $root_dir`;

    if ($mounted_fs ne "") {
        my @mounted_fs = split /\n/, $mounted_fs;
        foreach (@mounted_fs) {
            $_ =~ s/\s.*//;
            my $ret = system("umount", $_);

            if ($ret != 0) {
                print STDERR "[error] something going wrong during umount of $_";
            }
        }
    }
}

sub mount_partitions {
    my $config = shift;
    my $image = shift;
    my $partitions = shift;
    my %partitions = %{$partitions};
    my $image_name = basename($image);
    my $root_dir = dirname($image) . "/$image_name-root";

    if (!defined($partitions{'/'})) {
        print STDERR "[error] no root partition found\n";
        return -1;
    }

    my $root_device = $partitions{'/'};

    # create root directory
    mkdir($root_dir);

    # mount root directory
    foreach (@{$config->{partitions}}) {
        if ($_->{mountPoint} eq '/') {
            my $fs_type = $_->{fs}[0]->{name};

            print "[info] mount / partition to $root_device with $fs_type fs\n";
            $_ = `mount -t $fs_type $root_device $root_dir >/dev/null 2>&1`;

            if ($? != 0) {
                print STDERR "[error] mount of $root_device to $root_dir failed\n";
                print STDERR "Try to execute mount -t $fs_type $root_device $root_dir manually\n";
                return -1;
            }
            
            last;
        }
    }

    #
    # TODO mount other directories
    #

    # TODO return path to root
    return $root_dir;
}

1;
