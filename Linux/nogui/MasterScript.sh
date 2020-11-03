#!bin/bash

echo "Do you want to update and upgrade the machine?(y/n)"
read answer1
if [ "$answer1" = 'y' ]; then
    sudo apt update
    sudo apt upgrade
fi

echo "Do you want to delete prohibited files off the machine?(y/n)"
read answer2
if [ "$answer2" = 'y' ]; then
        ./SearchFiles.sh
fi

echo "enable firewall?(y/n)"
read answer3
if [ "$answer3" = 'y' ]; then
        sudo ufw enable
	      sudo ufw status
fi

echo "next question?(y/n)"
read answer4
if [ "$answer4" = 'y' ]; then
  echo this
fi
