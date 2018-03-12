#!/usr/bin/env perl
#
# The build-system is Copyright (C) 2017 Alexander Kuleshov <kuleshovmail@gmail.com>,
#
# Github: https://github.com/0xAX/build-system

use File::Copy;
use Data::Dumper;

sub process_local_initrd {
    my $root = shift;
    my $initrd = shift;
    my $initrd_path = '';

    if (!defined($initrd->{path})) {
        $initrd_path = "./initrds/x86_64/initrd_x86_64.cpio.gz"    
    } else {
        $initrd_path = $initrd->{path};
    }

    # put initramfs image to /boot directory
    print "[info] copying $initrd_path to $root/boot\n";
    $initrd_path = `echo $initrd_path`;
    copy($initrd_path, $root . "/boot");
}

sub provision_initramfs {
    my $config = shift;
    my $root = shift;

    die "[error] mandatory field in specification is missed - initrd."
        unless defined($config->{initrd});

    my $initrd = $config->{initrd};

    if (!defined($initrd->{type})) {
        return process_local_initrd($root, $initrd);
    }
    elsif ($initrd->{type} eq 'local') {
        return process_local_initrd($root, $initrd);
    }
    elsif ($initrd->{type} eq 'dracut') {
        print STDERR "[error] dracut initramfs is not supported for now\n";
        return -1;
    }
    elsif ($initrd->{type} eq 'docker') {
        print STDERR "[error] docker initramfs is not supported for now\n";
        return -1;
    }
    else {
        print STDERR "[error] not supported type of initramfs - $initrd->{type}\n";
        return -1;
    }
}

1;
