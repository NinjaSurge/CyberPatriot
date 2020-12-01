
# WIP Not Finished
# Run with the MasterScript with sudo for best results

# Blanks the file scriptScript
printf "" > ./scriptScript

# y's or n's only please
echo n >> ./scriptScript # Don't change this line this won't work

# User's Password


#Would you like to Update or Upgrade your machine?
echo n >> ./scriptScript

#Would you like to delete prohibited files?
answer2=n
echo $answer2 >> ./scriptScript
if [ $answer2 = y ]; then
  # Path to search
  echo "/home/$USER" >> ./scriptScript
  # File types to remove
  echo "mp3" >> ./scriptScript
fi

#Would you like to enable the firewall?
echo n >> ./scriptScript

#Would you like to add users?
answer4=y
name1="UserName"
echo $answer4 >> ./scriptScript
if [ $answer4 = y ]; then
  echo $name1 >> ./scriptScript
  # Would you like to add more users?
  echo n >> ./scriptScript
fi

#Would you like to remove users?
answer5=y
echo $answer5 >> ./scriptScript
# if [ $answer5 = y ]; then
#   # echo "n until the desired user is selected" >> ./scriptScript
# fi

#Would you like to add a Administrator?
answer6=n
echo $answer6 >> ./scriptScript
# if [ $answer6 = y ]; then
#   # echo "n until the desired user is selected" >> ./scriptScript
# fi

#Would you like to remove a Administrator?
answer7=n
echo $answer7 >> ./scriptScript
# if [ $answer7 = y ]; then
#   # echo "n until the desired user is selected" >> ./scriptScript
# fi

# Would you like to change User/Administrator passwords?
# answer5=y
# NewPassword1="NewPassword1"
# echo $answer5 >> ./scriptScript
# if [ $answer5 = y ]; then
#
#   echo $NewPassword1 >> ./scriptScript
#
#   echo n >> ./scriptScript
#
# fi
