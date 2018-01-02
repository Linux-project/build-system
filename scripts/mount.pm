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
    my $root_dir = dirname($image);

    if (!defined($partitions{'/'})) {
        print STDERR "[error] no root partition found\n";
        return -1;
    }

    my $root_device = $partitions{'/'};

    # create root directory
    mkdir(dirname($image) . "/$image_name-root");

    # mount root directory
    foreach (@{$config->{partitions}}) {
        if ($_->{mountPoint} eq '/') {
            last;
        }
    }

    #
    # TODO mount other dirs
    #

    # TODO return path to root
    return $root_dir . "/$image_name-root";
}

1;
