#!/bin/bash


echo "Welcome to Pixarch Installation Script"

export LINKDOT=${PWD%/*}

sudo pacman -S  go neovim htop firefox xorg-server xorg-xinit xorg-xrdb xorg-xprop \
		rofi exa pavucontrol tmux pamixer fzf xdg-user-dirs plank sddm \
		feh git openssh alacritty picom polybar dash NetworkManager xss-lock --needed

sudo ln -sfT dash /usr/bin/sh
mkdir -p ~/.config ~/code/aur ~/code/rice
xdg-user-dir

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
export PATH=$PATH:/home/$USER/.local/bin

read -p "-- install yay as aur helper?"
case $yna in
           [Yy]* ) git clone https://aur.archlinux.org/yay.git ~/code/aur/yay
cd ~/code/aur/yay
makepkg -si
yay -S ttf-monocraft
		;;
	* ) echo "-- you're on your own for the aur, which means fonts won't be autoinstalled.";;

read -p "-- Would you like to install i3? If you are looking for Qtile say no [y/N] " yna
case $yna in
            [Yy]* ) pacman -S i3-wm
		    ln -sf $LINKDOT/flavours/i3 /home/$USER/.config/
		                       ;;
                        * ) echo "-- skipping";;
esac

read -p "-- Would you like to install Qtile?" yna
case $yna in
            [Yy]* ) pacman -S qtile
		    ln -sf $LINKDOT/flavours/qtile /home/$USER/.config/
		                       ;;
                        * ) echo "-- if you didn't install i3 or this, you're on your own for a GUI.";;
esac

ln -sf $LINKDOT/.config/* /home/$USER/.config/
read -p "-- enter sudo password to cp grub theme and sddm theme to correct locations and fix the config files. otherwise skip configuring both. Understand? [y/N] " yna
case $yna in
	[Yy]* ) sudo cp $LINKDOT/boot/grub/grubel /boot/grub/
		sudo cp $LINKDOT/boot/sddm/themes/pixarch_sddm /usr/share/sddm/themes/
		sudo sed 's/\#GRUB_THEME/GRUB_THEME=\"\/boot\/grub\/grubel\/theme.txt\"/' -i /mnt/etc/default/grub
                sudo echo "'[Theme]
			   pixarch_sddm' >> /etc/sddm.conf.d/theme.conf" ;;
			* ) echo "-- you're on your own for theming.";;
esac

