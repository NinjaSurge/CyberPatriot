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

echo "Remove Users?(y/n)"
read answer4
if [ "$answer4" = 'y' ]; then
  awk -F: '{ print $1 }' /etc/passwd > users.txt

  printf "" > users_.txt
  while IFS= read -r line; do

    user_=$(id -u $line)

    if [ $user_ -gt 999 ]; then
      id -un "$user_" >> users_.txt
    fi
  done <users.txt
  cat ./users_.txt

  while IFS= read -r line; do
    echo ""
    echo "Do you want to remove \"$line\"?(y/n)"
    echo -n "Your answer is... : "
    read -t 15 remove <&1
    if [ $remove = y ]; then
      echo "Removing \"$line\""
      sudo userdel -r "$line"
    else
      echo "Not removing \"$line\""
    fi
  done <users_.txt

  rm ./users_.txt
  rm ./users.txt
fi

echo "Add Users?(y/n)"
read answer3
if [ "$answer3" = 'y' ]; then
  loop="yes"
  while [ $loop == "yes" ]; do
    echo "What's the new user's name?"
    read name
    sudo useradd $name
    echo "Add another User?(y/n)"
    read addAnotherUser
    if [ $addAnotherUser == "y" ]; then
      loop="yes"
    else
      loop=""
    fi
  done
fi

echo "End of Script"
