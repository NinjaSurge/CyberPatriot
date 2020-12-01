#!/bin/bash
fileLocation="/etc/pam.d/common-password"

echo
echo
echo "========pam_unix.so========"
echo
echo -e "--------Original--------"
grep "pam_unix.so" $fileLocation
echo
echo -e "--------New--------"
pam_unix=$(grep -nP "pam_unix.so" $fileLocation | sed 's/:/\n/' | sed '2d')
Comment=$(grep -nP "# Modified by a NinjaSurge Script" $fileLocation | sed 's/:/\n/' | sed -n '2~2!p' | grep -o "$pam_unix")
if [[ $pam_unix -ne $Comment ]]; then
  # echo "yes"
  sed -i '/pam_unix.so/ s/$/ minlen=8 remember=5\t# Modified by a NinjaSurge Script/' $fileLocation
fi
cat $fileLocation | grep -P "pam_unix.so"
echo
echo "________pam_unix________"

# install libpam-cracklib for this next one
echo
echo
echo "========pam.cracklib.so========"
echo
echo -e "--------Original--------"
grep "pam.cracklib.so" $fileLocation
echo
echo -e "--------New--------"
pam_cracklib=$(grep -nP "pam.cracklib.so" $fileLocation | sed 's/:/\n/' | sed '2d')
Comment2=$(grep -nP "# Modified by a NinjaSurge Script" $fileLocation | sed 's/:/\n/' | sed -n '2~2!p' | grep -o "$pam_cracklib")
if [[ $pam_cracklib -ne $Comment2 ]]; then
    sed -i '/pam.cracklib.so/ s/$/ ucredit=-1 lcredict=-1 dcredit=-1 ocredit=-1\t# Modified by a NinjaSurge Script/' $fileLocation
fi
cat $fileLocation | grep -P "pam.cracklib.so"
echo
echo "________pam.cracklib.so________"
