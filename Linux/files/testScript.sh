#!/bin/bash

if [ "$1" == "files" ]; then
  for i in {1..4}; do
    touch this$i.mp4
    touch this$i.mp3
    touch this$i.jpg
  done
elif [ "$1" == "users" ]; then
  if [ "$2" != "" ]; then
    sudo useradd "$2"
  else
    for i in {1..2}; do
      sudo useradd name$i
    done
  fi
fi
