#!/bin/bash

echo "Which user's password do you want to change?"
read userToChange

sudo passwd "$userToChange"