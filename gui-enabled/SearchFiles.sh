#! /usr/bin/env bash
# -TODO- path automation
location=`zenity --width=500 --height=400 --title="What path do you want to search?" \
	--file-selection --directory`

if [[ $? -eq 1 ]]; then
	zenity --error --title="Search Declined" --width=200 \
       --text="File search skipped"
	exit 1
fi
# echo "What file types do you want deleted?"
# read type
type=`zenity --width=500 --height=400 --title="Choose a file extension" \
	--list --radiolist \
	--column 'Selection' \
	--column 'Type' TRUE "mp3" FALSE "jpg"`

if [[ $? -eq 1 ]]; then
	zenity --error --title="Search Declined" --width=200 \
       --text="File search skipped"
	exit 1
fi

# echo "Finding and deleting $type files."

readFiles() {
  sudo find $location -name "*.$type" > fileDir
}

readLog() {
  echo "------These are the files to be deleted------"
  while IFS= read -r line || [ -n "$line" ]; do
  	echo "$line" 
  done <fileDir
}

delete() {
  while IFS= read -r line || [ -n "$line" ]; do
    rm "$line"
  done <fileDir
}

cleanUp() {
  rm fileDir
}
readFiles
readLog
delete
cleanUp