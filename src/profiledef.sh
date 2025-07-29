#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="berserkarch"
iso_label="BERSERKARCH_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="Gaurav Raj (@thehackersbrain) <gauravraj@berserkarch.xyz>"
iso_application="Berserk Arch VM Live/Installation/Rescue CD"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
# gpg_key="B024DCEFADEF4328B5E3A848E7E0F2B78484DACF"
# gpg_signing_key="B024DCEFADEF4328B5E3A848E7E0F2B78484DACF"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito'
  'uefi-ia32.grub.esp' 'uefi-x64.grub.esp'
  'uefi-ia32.grub.eltorito' 'uefi-x64.grub.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:0400"
  ["/etc/sudoers.d"]="0:0:750"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/customize_airootfs.sh"]="0:0:755"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
)
