#!/usr/bin/env bash

echo "Updating grub boot parameters"
sudo sed -i 's|GRUB_CMDLINE_LINUX=""|GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"|g' /etc/default/grub
sudo update-grub
sudo update-grub2
sudo reboot
