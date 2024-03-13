#!/bin/bash
echo "###  Mise en veille du système"
echo ""
echo "La commande systemctl suspend va etre executee .... "
echo ""
read -p "Do you want to proceed? (yes/no) " yn
case $yn in 
	yes ) echo ok, we will proceed;;
	no ) echo exiting...;
		exit;;
	* ) echo invalid response;
		exit 1;;
esac
systemctl suspend
echo ""
echo ""
echo ""
echo ""
echo ""
