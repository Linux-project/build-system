#
# The build-system is Copyright (C) 2017 Alexander Kuleshov <kuleshovmail@gmail.com>,
#
# Github: https://github.com/0xAX/kernel-dev/tree/master/kernel-testing

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
    print "[info] copying $initrd_path to $root/boot";
    copy($initrd_path, $root . "/boot");
}

sub process_docker_initrd {
    my $root = shift;
}

sub provision_initramfs {
    my $config = shift;
    my $root = shift;
    my $type = '';

    die "[error] mandatory field in specification is missed - initrd."
        unless defined($config->{initrd});

    my $initrd = $config->{initrd};

    if (!defined($initrd->{type})) {
        $type = 'local';
    } else {
        $type = $initrd->{type};
    }

    if ($type eq 'local') {
        return process_local_initrd($root, $initrd);
    }
    elsif ($type eq 'docker') {
        return process_docker_initrd($root, $initrd);        
    }
}

1;
