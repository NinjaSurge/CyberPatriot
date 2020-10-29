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
  	--column 'Options' TRUE "Both" FALSE "Update" FALSE "Upgrade" FALSE "Neither"`
  	
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

	elif [ $update_ == "Neither" ]; then
		zenity --width=200 --info --title="You Chose Nothing" \
			--text="You chose not to update or upgrade."
	
	fi
}

searchFiles() {
	bash ./SearchFiles.sh "$sudoPassword" >${TempFile}
	if [ $? -eq 0 ]; then 
		informationOutput "Search Completed"
	fi
}

enableFirewall() {
	zenity --question --width=300 --title="Enable firewall" --text="Do you want to enable the firewall?(via ufw)"
	if [ $? -eq 0 ]; then 
		echo $sudoPassword | sudo -S ufw enable
		echo $sudoPassword | sudo -S ufw status >${TempFile}
		informationOutput "Firewall enabling result"
	else
		zenity --info --width=200 --title="Continue" --text="You choose not to enable the firewall"
	fi
}

if [ $? -eq 0 ]; then
	updateMachine
	searchFiles
	enableFirewall

	zenity --info --title="Script End" --text="This is the end of the script. Hope it helped!"
else
	zenity --error --width=300 --title="No Password" --text="No password no script!"
fi