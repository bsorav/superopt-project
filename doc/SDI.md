# Installation via CD/DVD

1. While booting the OS from a CD/DVD, set "fsck.mode=skip" to the kernel boot params (after /casper/vmlinuz) via GRUB menu entry. See https://bugs.launchpad.net/ubuntu/+source/casper/+bug/1930880
2. Install Docker using the instructions in doc/Docker.md
3. Load the docker image using the instructions in README.md
