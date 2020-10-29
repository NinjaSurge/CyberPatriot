#!bin/bash

TempFile=$(mktemp)

sudoPassword=`zenity --password --title="Password for $USER"`

informationOutput() {
	zenity --width=600 --height=800 \
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
  			echo $sudoPassword | sudo -S apt update | tee >(zenity --width=200 --height=100 \
	    	 --title="Collecting Information" --progress \
	    	 --pulsate --text="Updating computer..." \
	    	 --auto-kill --auto-close) >${TempFile}
  			
  			echo "" >> ${TempFile} \
  			
  			echo "---------------------The Upgrade is listed below---------------------" >> ${TempFile} \
  			
  			echo "" >> ${TempFile} \
  			
  			echo $sudoPassword | sudo -S apt upgrade | tee >(zenity --width=200 --height=100 \
	    	 --title="Collecting Information" --progress \
	    	 --pulsate --text="Upgrading computer..." \
	    	 --auto-kill --auto-close) >>${TempFile}

  			informationOutput "Update and Upgrade Information"
		fi
		
		if [ $update_ == "Update" ]; then
			
			# Update and pipe the output to the file 
			# TempFile while displaying a loading window
			echo $sudoPassword | sudo -S apt update | tee >(zenity --width=200 --height=100 \
	    	 --title="Collecting Information" --progress \
	    	 --pulsate --text="Updating computer..." \
	    	 --auto-kill --auto-close) >${TempFile}

			# Adding Extra information to the file to be displayed
			echo "---------------------The upgradable files below---------------------" >>${TempFile}
			apt list --upgradable >>${TempFile}

			informationOutput "Update Information"

			UpgradeQ=`zenity --title="Upgrade?" \
			--list --radiolist --text="Would you like to upgrade the computer now?" \
			--column 'Selection' \
			--column 'Answer' TRUE "Yes" FALSE "No"`
		fi
		
		if [ "$update_" == "Upgrade" ] || [ "$UpgradeQ" == "Yes" ]
		then
			echo $sudoPassword | sudo -S apt upgrade | tee >(zenity --width=200 --height=100 \
	    	 --title="Collecting Information" --progress \
	    	 --pulsate --text="Upgrading computer..." \
	    	 --auto-kill --auto-close) >${TempFile}

			informationOutput "Upgrade Information"
		fi

	elif [ $update_ == "Neither" ]; then
		zenity --width=500 --height=400 --info --title="You Chose Nothing" \
		--text="You chose to do neither update nor upgrade."
	
	fi
}

# echo "Do you want to update and upgrade the machine?(y/n)"
# read answer1
# if [ "$answer1" = 'y' ]; then
# 	updateMachine
# fi

# echo "Do you want to delete prohibited files off the machine?(y/n)"
# read answer2
# if [ "$answer2" = 'y' ]; then
#         ./SearchFiles.sh
# fi

# echo "enable firewall?(y/n)"
# read answer3
# if [ "$answer3" = 'y' ]; then
#         sudo ufw enable
# 		sudo ufw status
# fi

if [ $? -eq 0 ]; then
	updateMachine
else
	zenity --error --title="No Password" --text="No password no script!"
fi