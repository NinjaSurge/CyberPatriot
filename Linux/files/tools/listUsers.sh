#!/bin/bash
awk -F: '{ print $1 }' /etc/passwd > users.txt
printf "" > users_.txt
while IFS= read -r line; do
  user_=$(id -u $line)
  if [ $user_ -gt 999 ]; then
    id -un "$user_" >> users_.txt
  fi
done <users.txt
cat users_.txt
rm ./users.txt
