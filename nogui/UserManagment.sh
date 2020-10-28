#!/bin/bash

ScriptDir=$(dirname $(readlink -f $0))
goodUsers=$ScriptDir/validUsers
UserVar=""
CUL=""

cleanUp() {
	findCurrentUserFile=$(find ./ -name currentUserFile)
	$findCurrentUserFile || rm -f ./currentUserFile 2> /dev/null

	findReadUserFile=$(find ./ -name readUser)
	$findReadUserFile || rm -f ./readUser 2> /dev/null
}

readGoodUser() {
	touch ./readGoodUser
	GUL=$(head -$1 "$goodUsers" | tail +$1)
	GUID=$(id -u "$GUL")
	echo "$GUL=$GUID" > readGoodUser
	cat ./readGoodUser
}

readUserList() 
{	
	touch ./readUser
	CUL=$(head -$1 /etc/passwd | tail +$1)
	echo "$CUL" > readUser
	userName=$(awk -F: '{print $1}' ./readUser)
	userId=$(awk -F: '{print $3}' ./readUser)
	echo "$userName=$userId" > readUser

	cat ./readUser
}

compareUsers() {
	readGoodUser $1
	readUserList $2
	GULID=$(awk -F= '{print $2}' ./readGoodUser)
	RULID=$(awk -F= '{print $2}' ./readUser)

#	while true; do
		if [ "$RULID" -gt 999 ]; then
			echo "$RULID isn't a system user"
			if [ "$RULID" -eq "$GULID" ]; then
				echo "$GULID == $RULID"
				echo "They are one and the same"
			fi
			while true; do
				if [ "$RULID" -ne $"GULID" ]; then 
					this
				fi
			done
		fi
#	done
}

 readGoodUser 20
 readUserList 41
# compareUsers 21 41
# cleanUp
