#!bin/bash

Tempfile=$(mktemp)

WhichHelp=`zenity --width=400 --height=275 --list --radiolist --window-icon=Icon.xpm\
     --title 'Zenity Help' \
     --text 'Select Help Topic:' \
     --column 'Select' \
     --column 'Help Item' TRUE "help" FALSE "help-all" FALSE "help-general" \
     FALSE "help-calender" FALSE "help-entry" FALSE "help-error" FALSE "help-info" \
     FALSE "help-file-selection" FALSE "help-list" FALSE "help-notification" \
     FALSE "help-progress" FALSE "help-question" FALSE "help-warning" \
     FALSE "help-scale" FALSE "help-text-info" FALSE "help-color-selection" \
     FALSE "help-password" FALSE "help-forms" FALSE "help-misc" FALSE "help-gtk"`

if [ $? -eq 1 ]; then
    exit 1
fi

zenity "--$WhichHelp" | tee >(zenity --width=200 --height=100 \
                --title="Help Progress" --progress \
                --pulsate --text="Getting the help you need!" \
                --auto-kill --auto-close) >${Tempfile}

zenity --title="Zenity Help" --width=500 --height=500 --window-icon=Icon.xpm \
--text-info --filename="${Tempfile}"

exit 0