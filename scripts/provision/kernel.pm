#!/usr/bin/env perl
#
# The build-system is Copyright (C) 2017 Alexander Kuleshov <kuleshovmail@gmail.com>,
#
# Github: https://github.com/0xAX/build-system

use File::Copy;
use Data::Dumper;

sub process_local_kernel {
    my $root = shift;
    my $kernel = shift;
    my $kernel_path = '';

    if (!defined($kernel->{path})) {
        print STDERR "[error] path to local kernel is not provided\n";
        return -1;
    } else {
        $kernel_path = $kernel->{path};
    }

    # put Linux kernel and related files to /boot directory
    print "[info] provision kernel\n";

    $kernel_path = `echo $kernel_path`;
    my $kernel_image = $kernel_path . "/arch/x86_64/boot/bzImage";
    my $system_map = $kernel_path . "/System.map";

    $kernel_image =~ s/[\r\n]//;
    $system_map =~ s/[\r\n]//;
    
    if (! -e $kernel_image || ! -e $system_map) {
        print STDERR "[error] Linux kernel image and System.map are not found in $kernel_path\n";
        return -1;
    }

    copy($kernel_image, $root . "/boot");
    copy($system_map, $root . "/boot");
}

sub provision_kernel {
    my $config = shift;
    my $root = shift;
    my $type = '';

    die "[error] mandatory field in specification is missed - kernel."
        unless defined($config->{kernel});

    my $kernel = $config->{kernel};

    if (!defined($kernel->{type})) {
        $type = 'local';
    } else {
        $type = $kernel->{type};
    }

    if ($type eq 'local') {
        return process_local_kernel($root, $kernel);
    }

    return -1;
}

1;
