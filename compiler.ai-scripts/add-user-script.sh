#!/bin/bash
username=$1
password=$2
getent passwd $username > /dev/null

if [ $? -ne 0 ]; then
	if [ $(id -u) -eq 0 ]; then
		#read -p "Enter username : " username
		#read -s -p "Enter password : " password
		egrep "^$username" /etc/passwd >/dev/null
		if [ $? -eq 0 ]; then
			echo "$username exists!"
			exit 1
		else
			pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
			useradd -m -p "$pass" "$username"
			[ $? -eq 0 ] && echo "User $username added successfully!" || echo "Failed to add a user $username!"
		fi
	else
		echo "Only root may add a user to the system."
		exit 2
	fi
fi
