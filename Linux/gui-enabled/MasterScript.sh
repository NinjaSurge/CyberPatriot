#!bin/bash

TempFile=$(mktemp)

if [ "$1" != "no-pass" ]; then
	sudoPassword=`zenity --password --title="Password for $USER"`
fi

if [ $? -eq 1 ]; then
	exit 1
fi

informationOutput() {
	zenity --width=600 --height=600 \
		 --title="$1" \
		 --text-info --filename="${TempFile}"
}

updateMachine() {
  	update_=`zenity --width=500 --height=400 --title="Update The Machine?" \
  	--text="Do you want to update and upgrade the machine" \
  	--list --radiolist \
  	--column 'Selection' \
  	--column 'Options' TRUE "Both" FALSE "Update" FALSE "Upgrade" FALSE "Full-Upgrade" FALSE "Dist-Upgrade" FALSE "Neither"`

  	if [ $update_ != "Neither" ]; then

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
			apt-get list --upgradable >>${TempFile}

			informationOutput "Update Information"

			UpgradeQ=`zenity --title="Upgrade?" \
			--list --radiolist --text="Would you like to upgrade the computer now?" \
			--column 'Selection' \
			--column 'Answer' TRUE "Yes" FALSE "No"`
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

	elif [ $update_ == "Neither" ]; then
		zenity --width=200 --info --title="You Chose Nothing" \
			--text="You chose not to update or upgrade."

	fi

}

searchFiles() {
	searchFilesLocation=./SearchFiles.sh
	findLocation=$(find ./ -name gui-enabled)
	if [ $findLocation ]; then
	  searchFilesLocation=./gui-enabled/SearchFiles.sh
	fi
	loop="Yes"
	while [ "$loop" == "Yes" ]; do
		bash $searchFilesLocation "$sudoPassword" >${TempFile}
		if [ $? -eq 0 ]; then
			informationOutput "Search Completed"
		fi
		loop=`zenity --title="Search Again?" \
			--list --radiolist --text="Would you like to search for another file type?" \
			--column 'Selection' \
			--column 'Answer' TRUE "Yes" FALSE "No"`
	done
}

enableFirewall() {
	zenity --question --width=300 --title="Enable firewall" \
		--text="Do you want to enable the firewall?(via ufw)"
	if [ $? -eq 0 ]; then
		echo $sudoPassword | sudo -S ufw enable
		echo $sudoPassword | sudo -S ufw status >${TempFile}
		informationOutput "Firewall enabling result"
	else
		zenity --info --width=200 --title="Continue" \
			--text="You choose not to enable the firewall"
	fi
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
		checkUsers=$(zenity --list --text "How linux.byexamples can be improved?" --checklist  --column "Pick" \
		--column "options" ${OptionsArray[@]} \
		--separator=":")

		echo $checkUsers > checkUsers | sed 's/:/\n/g' ./checkUsers > NewCheckUsers

		cat NewCheckUsers > ./checkUsers
		cat ./checkUsers

		while IFS= read -r line; do
			echo $sudoPassword | sudo -S userdel -r $line
		done < ./checkUsers

		rm ./users_.txt
		rm ./users.txt
		rm ./NewCheckUsers
		rm ./checkUsers
	else
		zenity --info --width=200 --title="Continue" \
			--text="You choose not to remove any users"
	fi
}

add_Users() {
	zenity --question --width=300 --title="Add Users" \
		--text="Do you want to add any users?"
	if [ $? -eq 0 ]; then
		loop="Yes"
		while [ "$loop" == "Yes" ]; do
			zenity --forms --title="Add Friend" \
				--text="Enter information about your friend." \
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
			echo "$username:$password" | sudo chpasswd

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
			loop=`zenity --title="Add More Users?" \
				--list --radiolist --text="Would you like to add another user?" \
				--column 'Selection' \
				--column 'Answer' TRUE "Yes" FALSE "No"`
		done
		# clean up
		rm ./NewUserList
	else
		zenity --info --width=200 --title="Continue" \
			--text="You choose not to add any users"
	fi
}


if [ $? -eq 0 ]; then
	updateMachine
	searchFiles
	enableFirewall
	add_Users
	removeUsers


	zenity --info --width=300 --title="Script End" \
		--text="This is the end of the script. Hope it helped!"
else
	zenity --error --title="No Password" --text="No password no script!"
fi
