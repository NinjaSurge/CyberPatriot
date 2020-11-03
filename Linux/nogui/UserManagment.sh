#!/bin/bash

ScriptDir=$(dirname $(readlink -f $0))
goodUsers=$ScriptDir/validUsers
UserVar=""
CUL=""

UserPaswords="???"

removeFile() {
	findReadUserFile=$(find ./ -name $1)
	$findReadUserFile || rm -f ./$1
}

cleanUp() {
	findCurrentUserFile=$(find ./ -name currentUserFile)
	$findCurrentUserFile || rm -f ./currentUserFile

	findReadUserFile=$(find ./ -name readUser)
	$findReadUserFile || rm -f ./readUser
}

readGoodUser() {
	touch ./readGoodUser
	GUL=$(head -$1 "$goodUsers" | tail +$1)
	GUID=$(id -u "$GUL")
	echo "$GUL=$GUID" > readGoodUser
	# cat ./readGoodUser
}

readUserList() 
{	
	touch ./readUser
	CUL=$(head -$1 /etc/passwd | tail +$1)
	echo "$CUL" > readUser
	# userName=$(awk -F: '{print $1}' ./readUser)
	userId=$(awk -F: '{print $3}' ./readUser)
	echo $userId > readUser
	# echo "$userName=$userId" > readUser

	# cat ./readUser
}


# To compare the users, we need to make sure that the ids are above 999 and 
# that they are on the list validUsers. If they aren't we need to (Ask to be certain) 
# remove them from the machine

# Would be nice to add/remove administrators too (Not the users just the privilages)
compareUsers() {
	linesInPasswd=$(cat /etc/passwd | wc -l)
	for ((number = 0; number<=$linesInPasswd; number++))
	do
		
		((number=number+1))
		
		readUserList $((number+1))
		RUL=$(cat ./readUser)

		if [ "$RUL" -gt 999 ]; then
			
			linesIn_validUsers=$(cat ./validUsers | wc -l)
			for ((number2=0; number2<=$linesIn_validUsers; number2++))
			do 
				((number2=number2+1))
				
				cat ./readUser
				readGoodUser $number2
				GUL=$(cat ./readGoodUser)
				cat ./readGoodUser
				
				((number2=number2-1))
			done
		
		fi

		((number=number-1))

	done
}

# readGoodUser
# readUserList
compareUsers

removeFile readGoodUser

cleanUp