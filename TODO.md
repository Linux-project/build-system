# TODO

## Linux kernel

  * Build tiny kernel
  * Build defconfig kernel
  * Build RT kernel
  * Build linux-next
  * Build linux kernel with dtrace support

## configuration

  * add `arch` field

## build-system

  * add ls command to inspec image.
  * add `-d,--debug` and print `Content of part file` if it was passed.
  * add `-v/--verbose`
  * add `--no-color`
  * support `--build-disk` and other `yml` based fields.
we may use `perl -e` during checking command line options here.
  * support `-o/--output-dir` command line option;
  * provide `--update-cofnigs` options to update `kernel-configs`.

## bootloader

  * Support images without bootloader, but use `-kernel` and other command
line arguments of qemu.

## partitions

  * Exit if bootable flag is not set.
  * support for GPT partitions

## mount

  * Add `mount_opts` field to `fs`
  * Check `mkdir` for root directory.

## Documentation

  * Provide info how to install dependencies for different platforms (Perl-Yaml and etc..)
  * add some docs to describe yaml fields.
  * Fill README.md
  * Add CONTRIBUTE.md
  * Add LICENSE
