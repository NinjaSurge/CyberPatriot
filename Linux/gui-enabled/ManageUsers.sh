#!/bin/bash

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
			sudo userdel -r $line
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
			sudo useradd -m $username

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

add_Users
removeUsers
