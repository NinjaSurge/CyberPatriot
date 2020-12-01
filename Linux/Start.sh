#!/usr/bin/env bash
echo "Do you want a gui for your script?"
echo "(!!Is currently Experimental and not as complete as the nogui version!!)"
echo "Type \"yes\" for the gui"
read answer
if [ "$1" == "test" ]; then
  bash ./files/testScript.sh $2
fi
if [ $answer = "yes" ]; then
  bash ./files/GuiMasterScript.sh $1
else
  bash ./files/NoguiMasterScript.sh $1
fi
