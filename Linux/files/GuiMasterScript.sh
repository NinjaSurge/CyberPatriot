#!bin/bash

TempFile=$(mktemp)

sudoPassword=`zenity --password --title="Password for $USER"`

if [ $? -eq 1 ]; then
	exit 1
fi

informationOutput() {
	zenity --width=600 --height=600 \
		 --title="$1" \
		 --text-info --filename="${TempFile}"
}

whatToDo() {
	userWants=$(zenity --width=800 --height=600 \
	--title="What do you want done?" \
	--list --checklist --editable --separator=":"\
	--column "Do" --column "This" \
								FALSE "updateMachine" \
								FALSE "searchFiles" \
								FALSE "enableFirewall" \
								FALSE "addGroups" \
								FALSE "removeGroups" \
								FALSE "removeUsers" \
								FALSE "addUsers" \
								FALSE "addAdmins")
	echo $userWants > userWants | sed 's/:/\n/g' ./userWants > NewUserWants
	cat NewUserWants > ./userWants
	cat ./userWants

	while IFS= read -r line; do
		$line
	done < ./userWants

	rm ./userWants
}

updateMachine() {
  	update_=`zenity --width=500 --height=400 --title="Update The Machine?" \
  	--text="Do you want to update and upgrade the machine" \
  	--list --radiolist \
  	--column 'Selection' \
  	--column 'Options' TRUE "Both" FALSE "Update" FALSE "Upgrade" FALSE "Full-Upgrade" FALSE "Dist-Upgrade" FALSE "Neither"`

  	if [ $update_ != "Neither" ] || [ $? != 1 ]; then

		if [ $update_ == "Both" ]; then
  			echo $sudoPassword | sudo -S apt-get update | tee >(zenity --width=200 --height=100 \
	    	 --title="Collecting Information" --progress \
	    	 --pulsate --text="Updating computer..." \
	    	 --auto-kill --auto-close) >${TempFile}

  			echo "" >> ${TempFile} \

  			echo "---------------------The Upgrade is listed below---------------------" >> ${TempFile} \

  			echo "" >> ${TempFile} \

  			echo $sudoPassword | sudo -S apt-get -y upgrade | tee >(zenity --width=200 --height=100 \
	    	 --title="Collecting Information" --progress \
	    	 --pulsate --text="Upgrading computer..." \
	    	 --auto-kill --auto-close) >>${TempFile}

  			informationOutput "Update and Upgrade Information"
		fi

		if [ $update_ == "Update" ]; then

			# Update and pipe the output to the file
			# TempFile while displaying a loading window
			echo $sudoPassword | sudo -S apt-get update | tee >(zenity --width=200 --height=100 \
	    	 --title="Collecting Information" --progress \
	    	 --pulsate --text="Updating computer..." \
	    	 --auto-kill --auto-close) >${TempFile}

			# Adding Extra information to the file to be displayed
			echo "---------------------The upgradable files below---------------------" >>${TempFile}
			apt list --upgradable >>${TempFile}

			informationOutput "Update Information"

			if zenity --question --width=200 --text="Would you like to upgrade the computer now?"; then
				UpgradeQ="Yes"
			else
				UpgradeQ="No"
			fi
		fi

		if [ "$update_" == "Upgrade" ] || [ "$UpgradeQ" == "Yes" ]
		then
			echo $sudoPassword | sudo -S apt-get upgrade -y | tee >(zenity --width=200 --height=100 \
	    	 --title="Collecting Information" --progress \
	    	 --pulsate --text="Upgrading computer..." \
	    	 --auto-kill --auto-close) >${TempFile}

			informationOutput "Upgrade Information"
		fi

		if [ $update_ == "Full-Upgrade" ]
		then
			echo $sudoPassword | sudo -S apt-get full-upgrade -y | tee >(zenity --width=200 --height=100 \
	    	 --title="Collecting Information" --progress \
	    	 --pulsate --text="Upgrading computer..." \
	    	 --auto-kill --auto-close) >${TempFile}

			informationOutput "Upgrade Information"
		fi

		if [ $update_ == "Dist-Upgrade" ]
		then
			echo $sudoPassword | sudo -S apt-get dist-upgrade -y | tee >(zenity --width=200 --height=100 \
	    	 --title="Collecting Information" --progress \
	    	 --pulsate --text="Upgrading computer..." \
	    	 --auto-kill --auto-close) >${TempFile}

			informationOutput "Upgrade Information"
		fi

		# claening up the updates and upgrades
		echo $sudoPassword | sudo -S apt-get autoremove

	fi

}

searchFiles() {
	zenity --question --width=300 --title="Search for files" \
		--text="Do you want search for prohibited files?"
	if [ $? -eq 0 ]; then

    location=`zenity --width=500 --height=400 --title="What path do you want to search?" \
    	--file-selection --directory`

    if [[ $? -eq 1 ]]; then
    	zenity --error --title="Search Declined" --width=200 \
           --text="File search skipped"
    	exit 1
    fi

    OptionsArray=()
    while IFS= read -r line; do
      OptionsArray+=( "FALSE $line" )
    done <./files/FileTypes.txt
    Types=$(zenity --width=500 --height=400 --title="Choose a file extension" \
		--list --text "File Type:" --checklist  --column "Remove" \
    --column "Types" ${OptionsArray[@]} \
    --separator=":" > searchFile)
    sed 's/:/\n/g' ./searchFile > ./newSearchFile
    cat ./newSearchFile > ./searchFile
    rm ./newSearchFile

		while IFS= read -r line; do
      echo "$sudoPassword" | sudo -S find $location -name "*.$line" | tee >(zenity --width=200 --height=100 \
			 --title="Collecting Information" --progress \
			 --pulsate --text="Searching..." \
			 --auto-kill --auto-close) >> found
    done < ./searchFile

		# zenity --warning --width=200 --text="Clicking ok on the following dialog will delete ALL of the listed files. \n\nIf you want ANY of the files kept remove the files by hand."

		# zenity --text-info --title="Files Found" --filename="./found"

    removeOptions=()
    while IFS= read -r line; do
      removeOptions+=( "FALSE $line" )
    done < ./found
    Choose=$(zenity --list --width=500 --height=400 --title="Remove Files" \
    --checklist --column "Remove" --column "Files" ${removeOptions[@]} \
    --separator=":" > ./remove)
    sed 's/:/\n/g' ./remove > ./newRemove
    cat ./newRemove > ./remove
    rm ./newRemove

    while IFS= read -r line; do
      rm $line
    done < remove

    # clean up
    rm ./found
    rm ./remove
    rm ./searchFile
	fi
}

enableFirewall() {
	zenity --question --width=300 --title="Enable firewall" \
		--text="Do you want to enable the firewall?(via gufw)"
	if [ $? -eq 0 ]; then
		echo $sudoPassword | sudo -S gufw
	fi
}

addGroups() {
	echo null
}

removeGroups() {
	echo null
}

removeUsers() {
	zenity --question --width=300 --title="Remove Users" \
		--text="Do you want to remove any users?"
	if [ $? -eq 0 ]; then
		awk -F: '{ print $1 }' /etc/passwd > users.txt

		printf "" > users_.txt
		while IFS= read -r line; do

			user_=$(id -u $line)

			if [ $user_ -gt 999 ]; then
				id -un "$user_" >> users_.txt
			fi
		done <users.txt

		OptionsArray=()
		while IFS= read -r line; do
			OptionsArray+=( "FALSE $line" )
		done <users_.txt
		checkUsers=$(zenity --list --text "Remove Users:" --checklist  --column "Remove" \
		--column "Users" ${OptionsArray[@]} \
		--separator=":")

		echo $checkUsers > checkUsers | sed 's/:/\n/g' ./checkUsers > NewCheckUsers

		cat NewCheckUsers > ./checkUsers
		cat ./checkUsers

		while IFS= read -r line; do
			sudo userdel -r $line
		done < ./checkUsers

		rm ./users_.txt
		rm ./users.txt
		rm ./NewCheckUsers
		rm ./checkUsers
	fi
}

addUsers() {
	zenity --question --width=300 --title="Add Users" \
		--text="Do you want to add any users?"
	if [ $? -eq 0 ]; then
		loop="Yes"
		while [ "$loop" == "Yes" ]; do
			zenity --forms --title="Add User" \
				--text="Enter the user's information." \
				--separator=":" \
				--add-entry="Full Name" \
			  --add-entry="Username" \
			  --add-password="Password" > TempNewUserList \
				--add-entry="Group"

			# seperates the : into new lines for easier parsing
			sed 's/:/\n/g' ./TempNewUserList > ./NewUserList

			# removes the now useless file
			rm ./TempNewUserList

			# assigns the name variable to the specified name
			name=$(sed -n '1p' ./NewUserList)

			# assigns the username variable to the specified username
			username=$(sed -n '2p' ./NewUserList)

			# assigns the password variable to the specified password
			password=$(sed -n '3p' ./NewUserList)

			# adds the user
			echo $sudoPassword | sudo -S useradd -m $username

			# gives the user the specified password
			if [[ $password == "" ]]; then
			  passwd -e $username
			else
				echo "$username:$password" | sudo chpasswd
			fi

			# deletes all entries but the group entries
			sed -i '1,3d' ./NewUserList

			# loops through the specified groups
			while IFS= read -r line; do
				# adds the user to the specified group
				sudo usermod -aG  $line $username
			# end of groups loop
			done < NewUserList

			zenity --info --title="Done" --text="User added"

			# asking if the user wants to end the loop
			if zenity --question --text="Would you like to add another user?"
		  then
		    loop="Yes"
		  else
		    loop=""
		  fi
		done
		# clean up
		rm ./NewUserList
	fi
}

addAdmins() {
  zenity --question --width=300 --title="Add Admin" \
    --text="Do you want to make any users Administrators?"
  if [ $? -eq 0 ]; then
    awk -F: '{ print $1 }' /etc/passwd > users.txt

    printf "" > users_.txt
    while IFS= read -r line; do

      user_=$(id -u $line)

      if [ $user_ -gt 999 ]; then
        id -un "$user_" >> users_.txt
      fi
    done <users.txt

    OptionsArray=()
    while IFS= read -r line; do
      OptionsArray+=( "FALSE $line" )
    done <users_.txt
    checkUsers=$(zenity --list --text "Make Admin:" --checklist  --column "Administrator" \
    --column "User" ${OptionsArray[@]} \
    --separator=":")

    echo $checkUsers > checkUsers | sed 's/:/\n/g' ./checkUsers > NewCheckUsers

    cat NewCheckUsers > ./checkUsers
    cat ./checkUsers

    while IFS= read -r line; do
        echo "Making $line an Administrator"
        sudo usermod -aG sudo $line
        sudo usermod -aG adm $line
    done < ./checkUsers

    rm ./users_.txt
    rm ./users.txt
    rm ./NewCheckUsers
    rm ./checkUsers
  fi
}

if [ $? -eq 0 ]; then
	if [ "$1" == "" ]; then
		whatToDo
		rm ./users_.txt
		rm ./NewUserList
		rm ./NewUserWants
		zenity --info --width=300 --title="Script End" \
			--text="This is the end of the script. Hope it helped!"
	elif [ "$1" != "" ] | [ $1 != "no-script" ]; then
		$1
	fi
else
	zenity --error --title="No Password" --text="No password no script!"
fi
