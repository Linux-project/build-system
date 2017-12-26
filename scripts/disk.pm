#!/usr/bin/env perl
#
# The build-system is Copyright (C) 2017 Alexander Kuleshov <kuleshovmail@gmail.com>,
#
# Github: https://github.com/0xAX/kernel-dev/tree/master/kernel-testing

use strict;
use warnings "all";
use diagnostics;

use Data::UUID;
use File::Basename;

# Global exit status
my $exit_status = 0;

sub gen_disk_name {
    my $spec_name = shift;
    my $uuid = Data::UUID->new;

    $spec_name = basename($spec_name);
    $spec_name =~ s/\..*//;
    $spec_name = $spec_name . "-" . $uuid->to_string($uuid->create());

    return $spec_name;
}

sub init_disk() {
    my $image_name = "";
    my $image_dir = "";
    my $disk_arg = shift;
    my $spec_name = shift;
    my $output_dir = shift;
    my $image_size = '10G';
    my $image_format = 'raw';

    die "Error: mandatory field in specification is missed - disk."
        unless defined($disk_arg->{disk});
    my $disk = $disk_arg->{disk};

    if (defined($disk->{name})) {
        $image_name = $disk->{name};
    } else {
        $image_name = gen_disk_name($spec_name);
    }

    if (defined($disk->{size})) {
        $image_size = $disk->{size};
    }

    if (defined($disk->{format})) {
        $image_format = $disk->{format};
    }

    # create directory with future image if it is not exists yet
    ($image_dir = $image_name) =~ s/\..*//;
    $image_dir = $output_dir . "/" . $image_dir;
    create_dir_if_not_exists($image_dir);

    if (! -f $image_dir . "/" . $image_name) {
        # create meta file
        open my $meta_fd, '>', $image_dir . "/" . ".meta";
        close($meta_fd);

        # create image
        $exit_status = system("qemu-img", "create",
                              "-f", $image_format,
                              $image_dir . "/" . $image_name,
                              $image_size, "-q");

        if ($exit_status != 0) {
            print STDERR "Error: something going wrong during disk creation\n";
            print STDERR "Probably disk options are wrong. Try to run manually:\n\n";
            print STDERR "  qemu-img create -f $image_format " . $image_dir . "/" . $image_name . " $image_size\n";
            exit $exit_status;
        }

        print "[info] raw image created: " . $image_dir . "/" . $image_name . "\n";
    }

    return ($image_dir, $image_dir . "/" . $image_name);
}

1;
