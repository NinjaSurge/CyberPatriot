#!/usr/bin/env bash
echo "Do you want a gui for your script?"
echo "(!!Is currently Experimental and not as complete as the nogui version!!)"
echo "Type \"yes\" for the gui"
read answer
if [ $answer = "yes" ]; then
  bash ./gui-enabled/MasterScript.sh
else
  bash ./nogui/MasterScript.sh
fi
