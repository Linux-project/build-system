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

    if (!defined($partitions{'/'})) {
        print STDERR "[error] no root partition found\n";
        return -1;
    }

    #
    # TODO mount root directory
    #

    #
    # TODO mount other dirs
    #

    # TODO return path to root
    return 1;
}

1;
