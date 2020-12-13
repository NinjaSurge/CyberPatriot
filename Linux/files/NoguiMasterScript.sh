#!bin/bash

updateUpgrade() {
  echo "Do you want to update AND upgrade the machine?(y/n)"
  read answer1
  if [ "$answer1" = 'y' ]; then
      sudo apt update
      sudo apt upgrade
  fi
}

searchFiles() {
  echo "Do you want to delete prohibited files off the machine?(y/n)"
  read answer2
  if [ "$answer2" = 'y' ]; then
    echo "What path do you want to search?"
    read location

    echo "What file types do you want deleted?"
    read type
    echo "Finding and deleting $type files."

    sudo find $location -name "*.$type" > fileDir
    echo "------These are the files to be deleted------"
    while IFS= read -r line || [ -n "$line" ]; do
    	echo "$line"
    done <fileDir
    while IFS= read -r line || [ -n "$line" ]; do
      rm "$line"
    done <fileDir
    rm fileDir
  fi
}

enableFirewall() {
  echo "enable firewall?(y/n)"
  read answer3
  if [ "$answer3" = 'y' ]; then
          sudo ufw enable
  	      sudo ufw status
  fi
}

addUsers() {

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
}

removeUsers() {
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
    echo
    echo "Here is a list of users: "
    echo
    while IFS= read -r line; do
      echo -e "\t$line"
    done <users.txt

    echo
    echo "To remove multipule users seperate the names by a ':'"
    echo
    echo -n "User(s) you want removed: "
    read -t 15 remove <&1
    echo $remove > ./remove
    sed -i 's/:/\n/g' ./remove
    cat ./remove
    while IFS= read -r line; do
      echo "Removing $line"
      sudo userdel -r "$line"
    done < ./remove
    rm ./users.txt
    rm ./remove
  fi
}

addAdministrators() {
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
      echo
      echo "Do you want to make $line an Administrator?(y/n)"
      echo -n "Your answer is... : "
      read -t 15 add <&1
      if [ $add = y ]; then
        echo "Making $line an Administrator"
        sudo usermod -aG sudo $line
        sudo usermod -aG adm $line
      else
        echo "Not making $line an Administrator"
      fi
    done <users_.txt
  fi
}

removeAdministrators() {
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

    echo
    echo "Here is a list of Administrators: "
    echo
    while IFS= read -r line; do
      echo -e "\t$line"
    done <Administrators.txt

    echo
    echo "To remove multipule Administrators seperate the names by a ':'"
    echo
    echo -n "Administrators(s) you want removed: "
    read -t 15 remove <&1
    echo $remove > ./remove
    sed -i 's/:/\n/g' ./remove
    cat ./remove

    while IFS= read -r line; do
        echo "Removing $line from Administrator"
        sudo deluser $line sudo
        sudo deluser $line adm
    done < ./remove

    rm ./Administrators.txt
    rm ./remove
  fi
}

login.defs() {
  echo "Configure login.defs?(y/n)"
  read answer7
  if [ "$answer7" = "y" ]; then
    # root is needed so the sed command can read and edit the files
    if [ "$EUID" -ne 0 ] ;
      then echo "Run as Root"
      exit
    fi

    fileLocation="/etc/login.defs"

    echo
    echo "________FAILLOG_ENAB________"
    echo -e "\t----Original----"
    grep FAILLOG_ENAB $fileLocation
    echo
    echo -e "\t----New----"
    sed -i 's/FAILLOG_ENAB\t\tno/FAILLOG_ENAB\t\tyes/' $fileLocation
    cat $fileLocation | grep FAILLOG_ENAB
    echo "--------FAILLOG_ENAB--------"

    echo
    echo
    echo "________LOG_UNKFAIL_ENAB________"
    echo -e "\t----Original----"
    grep -P "LOG_UNKFAIL_ENAB\t" $fileLocation
    echo
    echo -e "\t----New----"
    sed -i 's/LOG_UNKFAIL_ENAB\tno/LOG_UNKFAIL_ENAB\tyes/' $fileLocation
    cat $fileLocation | grep LOG_UNKFAIL_ENAB
    echo "--------LOG_UNKFAIL_ENAB--------"

    echo
    echo
    echo "________SYSLOG_SU_ENAB________"
    echo -e "\t----Original----"
    grep SYSLOG_SU_ENAB $fileLocation
    echo
    echo -e "\t----New----"
    sed -i 's/SYSLOG_SU_ENAB\t\tno/SYSLOG_SU_ENAB\t\tyes/' $fileLocation
    cat $fileLocation | grep SYSLOG_SU_ENAB
    echo "--------SYSLOG_SU_ENAB--------"

    echo
    echo
    echo "________SYSLOG_SG_ENAB________"
    echo -e "\t----Original----"
    grep -P "SYSLOG_SG_ENAB\t\t" $fileLocation
    echo
    echo -e "\t----New----"
    sed -i 's/SYSLOG_SG_ENAB\t\tno/SYSLOG_SG_ENAB\t\tyes/' $fileLocation
    cat $fileLocation | grep -P "SYSLOG_SG_ENAB\t\t"
    echo "--------SYSLOG_SG_ENAB--------"

    echo
    echo
    echo "________PASS_MIN_DAYS________"
    echo -e "\t----Original----"
    grep "^PASS_MIN_DAYS\t*" $fileLocation
    echo
    echo -e "\t----New----"
    sed -i '/PASS_MIN_DAYS\t[0-9]/ c PASS_MIN_DAYS\t10' $fileLocation
    cat $fileLocation | grep "^PASS_MIN_DAYS\t*"
    echo "--------PASS_MIN_DAYS--------"

    echo
    echo
    echo "________PASS_MAX_DAYS________"
    echo "----Original----"
    grep -P "PASS_MAX_DAYS\t[0-9]" $fileLocation
    echo
    echo "----New----"
    sed -i '/PASS_MAX_DAYS\t[0-9]/ c PASS_MAX_DAYS\t90' $fileLocation
    cat $fileLocation | grep -P "PASS_MAX_DAYS\t[0-9]"
    echo "--------PASS_MAX_DAYS--------"

    echo
    echo
    echo "________PASS_WARN_AGE________"
    echo "----Original----"
    grep -P "PASS_WARN_AGE\t[0-9]" $fileLocation
    echo
    echo "----New----"
    sed -i '/PASS_WARN_AGE\t[0-9]/ c PASS_WARN_AGE\t7' $fileLocation
    cat $fileLocation | grep -P "PASS_WARN_AGE\t[0-9]"
    echo "--------PASS_WARN_AGE--------"
  fi
}

sshd_config() {
  echo "Configure ssh?(y/n)"
  read answer7
  if [ "$answer7" = "y" ]; then

    fileLocation="/etc/ssh/sshd_config"
    echo
    echo "========LoginGraceTime========"
    echo
    echo -e "--------Original--------"
    grep "LoginGraceTime" $fileLocation
    settingName=$(grep -nP "LoginGraceTime" $fileLocation | sed 's/:/\n/' | sed '2d')
    Comment=$(grep -nP "# Modified by a NinjaSurge Script" $fileLocation | sed 's/:/\n/' | sed -n '2~2!p' | grep -o "$settingName")
    if [[ $settingName -ne $Comment ]]; then
      # echo "yes"
      sed -i 's/LoginGraceTime [0-9]m/LoginGraceTime 60# Modified by a NinjaSurge Script/' $fileLocation
    fi
    echo
    echo "========PermitRootLogin========"
    echo
    echo -e "--------Original--------"
    grep -E "(^PermitRootLogin|#PermitRootLogin)" $fileLocation
    settingName=$(grep -En "(^PermitRootLogin|#PermitRootLogin)" $fileLocation | sed 's/:/\n/' | sed '2d')
    Comment=$(grep -nP "# Modified by a NinjaSurge Script" $fileLocation | sed 's/:/\n/' | sed -n '2~2!p' | grep -o "$settingName")
    if [[ $settingName -ne $Comment ]]; then
      # echo "yes"
      sed -i -E 's/(^PermitRootLogin|#PermitRootLogin)/& no# Modified by a NinjaSurge Script/g' $fileLocation
    fi
    echo
    echo "========PermitEmptyPasswords========"
    echo
    echo -e "--------Original--------"
    grep -E "(^PermitEmptyPasswords|#PermitEmptyPasswords)" $fileLocation
    settingName=$(grep -En "(^PermitEmptyPasswords|#PermitEmptyPasswords)" $fileLocation | sed 's/:/\n/' | sed '2d')
    Comment=$(grep -nP "# Modified by a NinjaSurge Script" $fileLocation | sed 's/:/\n/' | sed -n '2~2!p' | grep -o "$settingName")
    if [[ $settingName -ne $Comment ]]; then
      # echo "yes"
      sed -i -E 's/(^PermitEmptyPasswords|#PermitEmptyPasswords)/& no# Modified by a NinjaSurge Script/g' $fileLocation
    fi
    echo
    echo "========PasswordAuthentication========"
    echo
    echo -e "--------Original--------"
    grep -E "(^PasswordAuthentication|#PasswordAuthentication)" $fileLocation
    settingName=$(grep -En "(^PasswordAuthentication|#PasswordAuthentication)" $fileLocation | sed 's/:/\n/' | sed '2d')
    Comment=$(grep -nP "# Modified by a NinjaSurge Script" $fileLocation | sed 's/:/\n/' | sed -n '2~2!p' | grep -o "$settingName")
    if [[ $settingName -ne $Comment ]]; then
      # echo "yes"
      sed -i -E 's/(^PasswordAuthentication|#PasswordAuthentication)/& yes# Modified by a NinjaSurge Script/g' $fileLocation
    fi
    echo
    echo "========X11Forwarding========"
    echo
    echo -e "--------Original--------"
    grep -E "(^X11Forwarding|#X11Forwarding)" $fileLocation
    settingName=$(grep -En "(^X11Forwarding|#X11Forwarding)" $fileLocation | sed 's/:/\n/' | sed '2d')
    Comment=$(grep -nP "# Modified by a NinjaSurge Script" $fileLocation | sed 's/:/\n/' | sed -n '2~2!p' | grep -o "$settingName")
    if [[ $settingName -ne $Comment ]]; then
      sed -i -E 's/(^X11Forwarding|#X11Forwarding)/& no# Modified by a NinjaSurge Script/g' $fileLocation
    fi
    echo
    echo "========UsePAM========"
    echo
    echo -e "--------Original--------"
    grep -E "(^UsePAM|#UsePAM)" $fileLocation
    settingName=$(grep -En "(^UsePAM|#UsePAM)" $fileLocation | sed 's/:/\n/' | sed '2d')
    Comment=$(grep -nP "# Modified by a NinjaSurge Script" $fileLocation | sed 's/:/\n/' | sed -n '2~2!p' | grep -o "$settingName")
    if [[ $settingName -ne $Comment ]]; then
      sed -i -E 's/(^UsePAM|#UsePAM)/& yes# Modified by a NinjaSurge Script/g' $fileLocation
    fi
    echo
    echo "========UsePrivilegeSeparation========"
    echo
    echo -e "--------Original--------"
    grep -E "(^UsePrivilegeSeparation|#UsePrivilegeSeparation)" $fileLocation
    settingName=$(grep -En "(^UsePrivilegeSeparation|#UsePrivilegeSeparation)" $fileLocation | sed 's/:/\n/' | sed '2d')
    Comment=$(grep -nP "# Modified by a NinjaSurge Script" $fileLocation | sed 's/:/\n/' | sed -n '2~2!p' | grep -o "$settingName")
    if [[ $settingName -ne $Comment ]]; then
      sed -i -E 's/(^UsePrivilegeSeparation|#UsePrivilegeSeparation)/& yes# Modified by a NinjaSurge Script/g' $fileLocation
    fi
    sed -i -E 's/# Modified by a NinjaSurge Script.*//' $fileLocation
    cat $fileLocation | grep "# Modified by a NinjaSurge Script"
  fi
}

changePasswords() {
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
    echo
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
        echo
        echo "Do you want to change $line's password?(y/n)"
        echo -n "Your answer is... : "
        read -t 15 change <&1
        if [ $change = y ]; then
          echo "Changing $line's password"
          sudo passwd $line <&1
        else
          echo "Not changing $line's password"
        fi
      done <users.txt

      echo "Change another password?(y/n)"
      read repeteQuestionAnswer
      if [ $repeteQuestionAnswer == "y" ]; then
        loop="yes"
      else
        loop=$repeteQuestionAnswer
      fi
    done
  fi
}

updateUpgrade
searchFiles
enableFirewall
addUsers
removeUsers
addAdministrators
removeAdministrators
login.defs
sshd_config
changePasswords

# Cleaning up unnessary files
  rm ./users.txt
  rm ./Administrators.txt

echo "End of Script"
