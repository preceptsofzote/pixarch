#!/bin/bash

printf "Security Configuration for Pixarch\n"
printf "Things that will be installed:\n1. UFW (Firewall)\n2. Clamav (Antivirus)\n"


printf "\nInstalling and Configuring UFW...\n"

sudo pacman -S ufw
sudo ufw enable 
sudo ufw allow ssh 
sudo ufw default allow outgoing 

printf "\nInstalled and Configured UFW\n"

printf "\nInstalling and Configuring Clamav..."

sudo pacman -S clamav

sudo freshclam

sudo systemctl enable --now clamav-daemon.service

printf "\nInstalled and Configured Clamav\n"

