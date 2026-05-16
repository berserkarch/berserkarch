#!/usr/bin/env bash

set -e -u

## -------------------------------------------------------------- ##

## Set zsh as default shell for new user
sed -i -e 's#SHELL=.*#SHELL=/bin/zsh#g' /etc/default/useradd

## -------------------------------------------------------------- ##

## Copy Few Configs Into Root Dir
rdir="/root/.config"
sdir="/etc/skel"
if [[ ! -d "$rdir" ]]; then
  mkdir "$rdir"
fi

systemctl enable NetworkManager.service

## Build the pacman keyring at ISO build time so it ships in the squashfs.
## Without this, the booted live system would need to run pacman-key at boot
## (slow GPG operations). The overlayfs makes /etc/pacman.d/gnupg/ writable
## at runtime, so pacman can update trust data normally.
pacman-key --init
pacman-key --populate

rcfg=('.oh-my-zsh' '.vim_runtime' '.vimrc' '.zshrc')
for cfile in "${rcfg[@]}"; do
  if [[ -e "$sdir/$cfile" ]]; then
    cp -rf "$sdir"/"$cfile" /root
  fi
done

## Populate liveuser home from skel
if [[ -d /home/liveuser ]]; then
  cp -rf "$sdir"/. /home/liveuser/
  chown -R 1000:1000 /home/liveuser/
fi

## -------------------------------------------------------------- ##

## Hide Unnecessary Apps
adir="/usr/share/applications"
apps=(avahi-discover.desktop bssh.desktop bvnc.desktop echomixer.desktop
  envy24control.desktop exo-preferred-applications.desktop feh.desktop
  hdajackretask.desktop hdspconf.desktop hdspmixer.desktop hwmixvolume.desktop lftp.desktop
  libfm-pref-apps.desktop lxshortcut.desktop lstopo.desktop
  networkmanager_dmenu.desktop nm-connection-editor.desktop pcmanfm-desktop-pref.desktop
  qv4l2.desktop qvidcap.desktop stoken-gui.desktop stoken-gui-small.desktop thunar-bulk-rename.desktop
  thunar-settings.desktop thunar-volman-settings.desktop yad-icon-browser.desktop)

for app in "${apps[@]}"; do
  if [[ -e "$adir/$app" ]]; then
    sed -i '$s/$/\nNoDisplay=true/' "$adir/$app"
  fi
done

## -------------------------------------------------------------- ##
