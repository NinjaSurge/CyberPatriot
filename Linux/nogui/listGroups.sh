#!/bin/bash
awk -F: '{printf "Group %s with GID=%d\n", $1, $3}' /etc/group > users.txt
printf "" > users_.txt
while IFS= read -r line; do
  user_=$(id -u $line)
  if [ $user_ -gt 999 ]; then
    id -un "$user_" >> users_.txt
  fi
done <users.txt
cat users_.txt
rm ./users.txt
