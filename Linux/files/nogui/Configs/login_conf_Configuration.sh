#!/bin/bash
# root is needed so the sed command can read and edit the files
if [ "$EUID" -ne 0 ] ;
	then echo "Run as Root"
	exit
fi

fileLocation="/etc/login.defs"

echo
echo "________FAILLOG_ENAB________"
echo -e "\t----Original----"
grep FAILLOG_ENAB $fileLocation
echo
echo -e "\t----New----"
sed -i 's/FAILLOG_ENAB\t\tno/FAILLOG_ENAB\t\tyes\t# Modified by a NinjaSurge Script/' $fileLocation
cat $fileLocation | grep FAILLOG_ENAB
echo "--------FAILLOG_ENAB--------"

echo
echo
echo "________LOG_UNKFAIL_ENAB________"
echo -e "\t----Original----"
grep -P "LOG_UNKFAIL_ENAB\t" $fileLocation
echo
echo -e "\t----New----"
sed -i 's/LOG_UNKFAIL_ENAB\tno/LOG_UNKFAIL_ENAB\tyes\t# Modified by a NinjaSurge Script/' $fileLocation
cat $fileLocation | grep LOG_UNKFAIL_ENAB
echo "--------LOG_UNKFAIL_ENAB--------"

echo
echo
echo "________SYSLOG_SU_ENAB________"
echo -e "\t----Original----"
grep SYSLOG_SU_ENAB $fileLocation
echo
echo -e "\t----New----"
sed -i 's/SYSLOG_SU_ENAB\t\tno/SYSLOG_SU_ENAB\t\tyes\t# Modified by a NinjaSurge Script/' $fileLocation
cat $fileLocation | grep SYSLOG_SU_ENAB
echo "--------SYSLOG_SU_ENAB--------"

echo
echo
echo "________SYSLOG_SG_ENAB________"
echo -e "\t----Original----"
grep -P "SYSLOG_SG_ENAB\t\t" $fileLocation
echo
echo -e "\t----New----"
sed -i 's/SYSLOG_SG_ENAB\t\tno/SYSLOG_SG_ENAB\t\tyes\t# Modified by a NinjaSurge Script/' $fileLocation
cat $fileLocation | grep -P "SYSLOG_SG_ENAB\t\t"
echo "--------SYSLOG_SG_ENAB--------"

echo
echo
echo "________PASS_MIN_DAYS________"
echo -e "\t----Original----"
grep "^PASS_MIN_DAYS\t*" $fileLocation
echo
echo -e "\t----New----"
sed -i '/PASS_MIN_DAYS\t[0-9]/ c PASS_MIN_DAYS\t10\t# Modified by a NinjaSurge Script' $fileLocation
cat $fileLocation | grep "^PASS_MIN_DAYS\t*"
echo "--------PASS_MIN_DAYS--------"

echo
echo
echo "________PASS_MAX_DAYS________"
echo "----Original----"
grep -P "PASS_MAX_DAYS\t[0-9]" $fileLocation
echo
echo "----New----"
sed -i '/PASS_MAX_DAYS\t[0-9]/ c PASS_MAX_DAYS\t90\t# Modified by a NinjaSurge Script' $fileLocation
cat $fileLocation | grep -P "PASS_MAX_DAYS\t[0-9]"
echo "--------PASS_MAX_DAYS--------"

echo
echo
echo "________PASS_WARN_AGE________"
echo "----Original----"
grep -P "PASS_WARN_AGE\t[0-9]" $fileLocation
echo
echo "----New----"
sed -i '/PASS_WARN_AGE\t[0-9]/ c PASS_WARN_AGE\t7\t# Modified by a NinjaSurge Script' $fileLocation
cat $fileLocation | grep -P "PASS_WARN_AGE\t[0-9]"
echo "--------PASS_WARN_AGE--------"
