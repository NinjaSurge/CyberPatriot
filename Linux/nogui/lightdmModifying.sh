#!/bin/bash

echo "This is the current lightdm configuration: "
cat /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf
echo
echo "Would you like to disable guest users?(y/n)"
read answer
if [ $answer = y ]; then
  sudo echo "allow-guest=false" >> /usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf
else
  echo "lightdm configuration not changed"
fi
