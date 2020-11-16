#!/bin/bash
awk -F: '{ print $1 }' /etc/passwd > users.txt
cat users.txt
rm ./users.txt
