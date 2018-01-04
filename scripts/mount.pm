#!/usr/bin/env perl
#
# The build-system is Copyright (C) 2017 Alexander Kuleshov <kuleshovmail@gmail.com>,
#
# Github: https://github.com/0xAX/kernel-dev/tree/master/kernel-testing

use Data::Dumper;

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

            #$_ = `mount -t $fs_type $root_device $root_dir`;

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
