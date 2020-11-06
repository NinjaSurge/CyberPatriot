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
	  cat ./users_.txt

	  while IFS= read -r line; do
			zenity --question --width=300 --title="Delete $line?" \
				--text="Do you want to remove $line and all their files?"
	    if [ $? -eq 0 ]; then
				echo $sudoPassword | sudo -S userdel -r "$line" | tee >(zenity --width=200 --height=100 \
		    	 --title="Collecting Information" --progress \
		    	 --pulsate --text="Upgrading computer..." \
		    	 --auto-kill --auto-close)
				if [ $? -eq 0 ]; then
					zenity --info --title="Removed Sucessfully" --text="$line removed sucessfully."
				else
					zenity --error --title="Removal Failed" --text="Removing $line failed."
				fi
	    fi
	  done <users_.txt
		rm ./users_.txt
		rm ./users.txt
	else
		zenity --info --width=200 --title="Continue" \
			--text="You choose not to remove any users"
	fi
}

if [ $? -eq 0 ]; then
	updateMachine
	searchFiles
	enableFirewall
	removeUsers

	zenity --info --width=300 --title="Script End" \
		--text="This is the end of the script. Hope it helped!"
else
	zenity --error --title="No Password" --text="No password no script!"
fi
