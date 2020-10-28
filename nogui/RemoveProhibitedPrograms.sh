#!/bin/bash

echo "What is the name of the app?"
read AppName

# read from a list of bad apps and remove them one by one

sudo apt remove --purge "$AppName"