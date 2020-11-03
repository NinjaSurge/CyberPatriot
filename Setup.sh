#!/usr/bin/env bash
echo "Do you want a gui for your script?(Is currently Experimental)"
echo "Type \"yes\" for the gui"
read answer
if [ $answer = "yes" ]; then
  bash ./gui-enabled/MasterScript.sh
else
  bash ./nogui/MasterScript.sh
fi
