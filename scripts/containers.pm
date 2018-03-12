#!/usr/bin/env perl
#
# The build-system is Copyright (C) 2017 Alexander Kuleshov <kuleshovmail@gmail.com>,
#
# Github: https://github.com/0xAX/build-system

use strict;
use warnings "all";
use diagnostics;

use Data::Dumper;

# Full list of build-system script related containers
my @CONTAINERS = qw(
    build-system
    grub
);

sub remove_docker_containers {
    if (! -e "/var/run/docker.sock") {
        print STDOUT "[warn] docker daemon is not runned\n";
        return -1;
    }

    foreach (@CONTAINERS) {
        my $container = `docker ps -a -f label=build-system=$_ --format "{{ .Names }}"`;
        
        chomp($container);

        if ($container ne '') {
            print STDOUT "[info] removing $container container...\n";
            `docker rm $container`;
        }
    }

    print STDOUT "[info] all containers related to build-system are removed\n";

    return 1;
}

sub remove_docker_images {
    if (! -e "/var/run/docker.sock") {
        print STDOUT "[warn] docker daemon is not runned\n";
        return -1;
    }

    foreach (@CONTAINERS) {
        if ($_ eq "build-system") {
            next;
        }

        my $image = `docker images -a -f \"label=build-system=$_\" --format={{.ID}}`;

        if ($image ne '') {
            chomp($image);

            print "[info] Removing $image image\n";

            # remove image
            `docker rmi -f $image`;

            # remove dangling images for non-base images
            `docker images -f dangling=true -q`   
        }
    }

    print STDOUT "[info] all images related to build-system are removed\n";

    return 1;    
}

1;
