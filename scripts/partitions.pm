#!/usr/bin/env perl
#
# The build-system is Copyright (C) 2017 Alexander Kuleshov <kuleshovmail@gmail.com>,
#
# Github: https://github.com/0xAX/kernel-dev/tree/master/kernel-testing

use strict;
use warnings "all";
use diagnostics;

use Data::Dumper;

sub is_disk_partitioned() {
    my $image = shift;
    $_ = `sfdisk -d $image 2>/dev/null`;

    if ($? == 256) {
        return 0;
    }

    return 1;
}

sub size_to_sectors {
    my $sectors = "";
    my $size = "";
    my $part_size = shift;

    if ($part_size =~ m/^[0-9].*GB$/) {
        $part_size =~ s/GB//;
        $sectors = ($part_size * 1024 * 1024 * 1024) / 512;
        return $sectors;
    }
    elsif ($part_size =~ m/^[0-9].*MB$/) {
        $part_size =~ s/MB//;
        $sectors = ($part_size * 1024 * 1024) / 512;
        return $part_size;
    }
    elsif ($part_size =~ m/^[0-9].*KB$/) {
        $part_size =~ s/KB//;
        $sectors = ($part_size * 1024) / 512;
        return $part_size;
    }
    else {
        print STDERR "[error] wrong partition size - $part_size\n";
        exit 1;
    }
}

sub create_partitions() {
    my $config = shift;
    my $image = shift;
    my $part_idx = 0;
    my $part_start = "2048";
    my $part_size = "";
    my $prev_part_size = "";
    my @hex_set = ('0' ..'9', 'a' .. 'f');
    my $label_id = join '' => map $hex_set[rand @hex_set], 1 .. 8;
    my $partition_spec = "/tmp/" . basename($image) . ".part";

    die "[error] mandatory field in specification is missed - partitions."
        unless defined($config->{partitions});
    my $partitions = $config->{partitions};

    print "[info] Creating partitions...\n";

    # delete partition specification if it is already exists
    if (-e $partition_spec) {
        unlink $partition_spec;
    }

    # create tmp files with partitions list
    open my $part_fd, '+>>', $partition_spec
        or die("[error] can't create spec file for partitions");

    # write partitions header
    print $part_fd "label: dos\n";
    print $part_fd "label-id: " . "0x" . $label_id . "\n";
    print $part_fd "device: " . basename($image) . "\n";
    print $part_fd "unit: sectors \n";
    print $part_fd "\n";

    foreach (@$partitions) {
        my $bootable = ",\tbootable";
        if (!defined($_->{bootable})) {
            $bootable = "";
        }

        $part_size = size_to_sectors($_->{size});

        # change partition start (for the first partition it is 2048 for now)
        if ($part_idx != 0) {
            $part_start = ($prev_part_size + $part_start);
        }

        print $part_fd basename($image) . " : start=\t" . $part_start
            . ", size=\t" . $part_size
            . ", type=\t" . $_->{type}
            . $bootable
            . "\n";
        $prev_part_size = $part_size + $part_start;
        $part_idx++;
    }

    if (0) {
        print "\nContent of $partition_spec:\n\n";
        local $/;
        seek($part_fd, 0, 0);
        my $part_content = <$part_fd>;
        print $part_content . "\n";
    }

    $_ = `sfdisk $image < $partition_spec 2>/dev/null`;

    if ($? != 0) {
        print STDERR "[error] occured during creation of partitions\n";
        print STDERR "[error] check your partitions configuration in $image\n";
        print STDERR "[error] partition scheme is dumped into $partition_spec\n";
        print STDERR "[error] try to execute: sfdisk $image < $partition_spec\n";
        print STDERR "manually to see errors.\n";
        exit 1;
    } else {
        print "[info] Partitions created successfully\n";
    }

    close($part_fd);

    return $partition_spec;
}

1;
