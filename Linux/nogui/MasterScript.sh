#!bin/bash

echo "Do you want to update and upgrade the machine?(y/n)"
read answer1
if [ "$answer1" = 'y' ]; then
    sudo apt update
    sudo apt upgrade
fi

echo ""

echo "Do you want to delete prohibited files off the machine?(y/n)"
read answer2
if [ "$answer2" = 'y' ]; then
  searchFilesLocation=./SearchFiles.sh
  findLocation=$(find ./ -name gui-enabled)
  if [ $findLocation ]; then
    searchFilesLocation=./nogui/SearchFiles.sh
  fi
        bash $searchFilesLocation
fi

echo "enable firewall?(y/n)"
read answer3
if [ "$answer3" = 'y' ]; then
        sudo ufw enable
	      sudo ufw status
fi

echo ""

echo "Add Users?(y/n)"
read answer5
if [ "$answer5" = 'y' ]; then
  loop="yes"
  while [ "$loop" == "yes" ]; do
    echo "What's the new user's name?"
    read name
    sudo useradd -m $name
    echo "Add another User?(y/n)"
    read addAnotherUser
    if [ $addAnotherUser == "y" ]; then
      loop="yes"
    else
      loop=""
    fi
  done
fi

echo ""

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

  cat ./users_.txt > users.txt
  rm ./users_.txt

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
  done <users.txt

  rm ./users_.txt
  rm ./users.txt
fi

echo ""

echo "Add Administrators?(y/n)"
read answer6
if [ $answer6 == y ]; then
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
    echo "Do you want to make \"$line\" an Administrator?(y/n)"
    echo -n "Your answer is... : "
    read -t 15 remove <&1
    if [ $remove = y ]; then
      echo "Making \"$line\" an Administrator"
      sudo usermod -aG sudo $line
      sudo usermod -aG adm $line
    else
      echo "Not making \"$line\" an Administrator"
    fi
  done <users_.txt
fi

echo ""

echo "Remove Administrators?(y/n)"
read answer7
if [ "$answer7" = "y" ]; then

  grep '^adm:.*$' /etc/group | cut -d: -f4 > Administrators_.txt
  head -1 Administrators_.txt | tr , \\n > Administrators.txt

  # resetting the Administrators_.txt file just in case
  printf "" > Administrators_.txt

  # check if the user is a system user,
  # if they aren't then read them to the file
  while IFS= read -r line; do
    user_=$(id -u $line)

    if [ $user_ -gt 999 ]; then
      id -un "$user_" >> Administrators_.txt
    fi
  done <Administrators.txt

  cat ./Administrators_.txt > Administrators.txt
  rm ./Administrators_.txt

  while IFS= read -r line; do
    echo ""
    echo "Do you want to remove \"$line\" from Administrator?(y/n)"
    echo -n "Your answer is... : "
    read -t 15 remove <&1
    if [ $remove = y ]; then
      echo "Removing \"$line\" from Administrator"
      sudo deluser $line sudo
      sudo deluser $line adm
    else
      echo "Not removing \"$line\" from Administrator"
    fi
  done <Administrators.txt

  rm ./Administrators.txt
fi

echo ""
echo "Here is the password status of the Users/Administrators"

awk -F: '{ print $1 }' /etc/passwd > users.txt

printf "" > users_.txt
while IFS= read -r line; do

  user_=$(id -u $line)

  if [ $user_ -gt 999 ]; then
    id -un "$user_" >> users_.txt
  fi
done <users.txt

cat ./users_.txt > users.txt
rm ./users_.txt

while IFS= read -r line; do
  echo ""
  echo "-------------------------$line-------------------------"
  sudo chage -l $line
  echo "--------------------------End--------------------------"
done <users.txt

echo 
echo "Change User/Administrator Passwords?(y/n)"
read answer8
if [ "$answer8" = 'y' ]; then
  loop="yes"
  while [ $loop == "yes" ]; do
#
#     awk -F: '{ print $1 }' /etc/passwd > users.txt
#
#     printf "" > users_.txt
#     while IFS= read -r line; do
#
#       user_=$(id -u $line)
#
#       if [ $user_ -gt 999 ]; then
#         id -un "$user_" >> users_.txt
#       fi
#     done <users.txt
#
#     cat ./users_.txt > users.txt
#     rm ./users_.txt
#
#     while IFS= read -r line; do
#       echo ""
#       echo "Do you want to change \"$line\"'s password?(y/n)"
#       echo -n "Your answer is... : "
#       read -t 15 change <&1
#       if [ $change = y ]; then
#         echo "Removing \"$line\""
#         sudo passwd $line
#       else
#         echo "Not changing \"$line\"'s password"
#       fi
#     done <users.txt
#
#     echo "Change another password?(y/n)"
#     read repeteQuestionAnswer
#     if [ $repeteQuestionAnswer == "y" ]; then
#       loop="yes"
#     else
#       loop=""
#     fi
#   done
# fi

sudo bash ./login_conf_Configuration.sh

# Cleaning up unnessary files
  rm ./users.txt
  rm ./Administrators.txt

echo "End of Script"

# ______Template Question__________
#
# echo ""
#
# echo "Question?(y/n)"
# read answer#
# if [ "$answer#" = 'y' ]; then
#
#  Do whaatever here
#
# fi

# ______Template Looping Question_____________
#
# echo ""
#
# echo "Initial Question?(y/n)"
# read answer#
# if [ "$answer#" = 'y' ]; then
#   loop="yes"
#   while [ $loop == "yes" ]; do
#
#     Do whaatever here
#
#     echo "Repete Question?(y/n)"
#     read repeteQuestionAnswer
#     if [ $repeteQuestionAnswer == "y" ]; then
#       loop="yes"
#     else
#       loop=""
#     fi
#   done
# fi
