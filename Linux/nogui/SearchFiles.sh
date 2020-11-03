#! /usr/bin/env bash
# -TODO- path automation
echo "What path do you want to search?"
read location

echo "What file types do you want deleted?"
read type
echo "Finding and deleting $type files."

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