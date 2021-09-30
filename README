Installation:

1. Download and uncompress spindle:
      https://github.com/asb/spindle/archive/master.zip

2. Download and uncompress torberry scripts and patch in the same folder

3. apply patch: 
      patch -p1 < spindle-fix.patch
      This patch is totally independent to torberry, contais minimal fixes
      in chroot binary path

4. Run spindle as described in their website:
      edit config and comment RASPBIAN=1 line (because raspbian does not have 
      x86 branch)
      sudo ./setup_spindle_environment  my_spindle_chroot
      edit config again and uncomment line
      sudo modprobe nbd max_part=16
      schroot -c spindle
      ./wheezy-stage0
      ./wheezy-stage1
      ./wheezy-stage2-torberry
      ./wheezy-stage3-torberry
      ./wheezy-stage4-torberry
      ./helper export_image_for_release out/stage4-torberry.qcow2 torberry.img
