#!/bin/bash

echo "Welcome to Pixarch Installation Script"

export LINKDOT=${PWD%/*}

sudo pacman -S  go vim htop firefox xorg-server xorg-xinit xorg-xrdb xorg-xprop \
		rofi exa pavucontrol tmux pamixer fzf xdg-user-dirs sddm lf \
		xclip feh openssh alacritty picom polybar xss-lock dialog dex \
		fish wget syncthing keepassxc --needed --noconfirm

mkdir -p ~/.config ~/code/aur
xdg-user-dir

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
export PATH=$PATH:/home/$USER/.local/bin
chsh -s /usr/bin/fish $USER

echo 'Installing yay as AUR helper, adding monocraft font, and adding multilib support'
REQUIRED_PKG="yay"
PKG_OK=$(pacman -Qi $REQUIRED_PKG|grep "Install Reason")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  git clone https://aur.archlinux.org/$REQUIRED_PKG
  cd $REQUIRED_PKG
  makepkg -si
        else
  echo 'yay already installed, thanks!'
fi
REQUIRED_PKG="ttf-monocraft"

PKG_OK=$(pacman -Qi $REQUIRED_PKG|grep "Install Reason")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
  	yay -S ttf-monocraft --answerdiff=None --noremovemake --pgpfetch --answerclean=None --noconfirm --asdeps
        sudo cp $LINKDOT/installation_scripts/Monocraft\ Nerd\ Font\ Complete\ Mono.ttf /usr/share/fonts/TTF/
        fc-cache -fv
        	else
  echo 'monocraft already installed, thanks!'
fi
	sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
	sudo sed -i "/Color/s/^#//;/Parallel/s/^#//;/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf
	sudo sed -i "s/-j2/-j16/;/^#MAKEFLAGS/s/^#//" /etc/makepkg.conf
	yay
REQUIRED_PKG="rofi-power-menu"

PKG_OK=$(pacman -Qi $REQUIRED_PKG|grep "Install Reason")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
yay -S rofi-power-menu
		else
  echo 'rofi power menu already installed, thanks!'
fi

i3=$(dialog --stdout --inputbox "Install i3? [y/N]" 0 0) || exit 1
clear
shopt -s nocasematch
if [[ $i3 =~ y ]]
then
	sudo pacman -S i3-wm --noconfirm
	ln -sf $LINKDOT/flavours/i3 /home/$USER/.config/
        
else
	echo "-- moving to Qtile"
fi

qtile=$(dialog --stdout --inputbox "Install Qtile? [y/N]" 0 0) || exit 1
clear
shopt -s nocasematch
if [[ $qtile =~ y ]]
then
	sudo pacman -S qtile --noconfirm
	ln -sf $LINKDOT/flavours/qtile /home/$USER/.config/
else 
	echo "-- if you didn't install i3 or Qtile, you're on your own for a GUI."
fi

ln -sf $LINKDOT/config/alacritty /home/$USER/.config/
ln -sf $LINKDOT/config/lf /home/$USER/.config/
ln -sf $LINKDOT/config/picom /home/$USER/.config/
ln -sf $LINKDOT/config/polybar /home/$USER/.config/
ln -sf $LINKDOT/config/rofi /home/$USER/.config/
ln -sf $LINKDOT/config/vim /home/$USER/.config/
ln -sf $LINKDOT/config/fish /home/$USER/.config/
ln -sf $LINKDOT/home/.bashrc /home/$USER/
ln -sf $LINKDOT/home/.tmux.conf /home/$USER/
ln -sf $LINKDOT/home/.Xresources /home/$USER/
ln -sf $LINKDOT/home/.dir_colors /home/$USER/
ln -sf $LINKDOT/home/.Xresources /home/$USER/.Xdefaults

theme=$(dialog --stdout --inputbox "Enter sudo password to copy Grub theme and SDDM theme to correct locations and fix the config files. Otherwise skip configuring both. Understand? [y/N]" 0 0) || exit 1
if [[ $theme =~ y ]]
then
	        sudo cp -r $LINKDOT/boot/grub/grubel /boot/grub/
		sudo cp -r $LINKDOT/boot/sddm/themes/pixarch_sddm /usr/share/sddm/themes/
		sudo sed 's/\#GRUB_THEME\=\"\/path\/to\/gfxtheme\"/GRUB_THEME=\"\/boot\/grub\/grubel\/theme.txt\"/' -i /etc/default/grub
                sudo cp $LINKDOT/installation_scripts/theme.conf /etc/sddm.conf
		sudo grub-mkconfig -o /boot/grub/grub.cfg
		sudo systemctl enable sddm
else 
	echo "Grub and SDDM theme not installed."
fi

browsel=$(dialog --stdout --inputbox "Install browsel for Private search and Web browser? [y/N]" 0 0) || exit 1
if [[ $browsel =~ y ]]
then
	echo 'installing searxng'
	cd ~/code/aur
	yay -G searxng-git
	cd searxng-git
	patch PKGBUILD -i $LINKDOT/applications/browsel/searxng.patch
	yay -S searxng-git --answerdiff=None --noremovemake --pgpfetch --answerclean=None --noconfirm --asdeps
	makepkg -si
	echo 'installing surf'
	cd ~/code/aur
	yay -G surf-git
	cd surf-git
	wget https://surf.suckless.org/patches/homepage/surf-2.0-homepage.diff
	sed 's/https\:\/\/duckduckgo\.com/http\:\/\/127.0.0.1\:8888/' -i surf-2.0-homepage.diff
	patch PKGBUILD -i $LINKDOT/applications/browsel/surf.patch
	makepkg -si
	echo 'installing tabbed'
	cd ~/code/aur
	yay -S tabbed-git
	git clone https://git.suckless.org/tabbed /home/$USER/code/tabbed
	cd /home/$USER/code/tabbed/
	wget https://tools.suckless.org/tabbed/patches/xresources/tabbed-xresources-20210317-dabf6a2.diff
	patch -p1 < tabbed-xresources-20210317-dabf6a2.diff
	cp $LINKDOT/applications/browsel/config.h .
	make
	sudo make clean install
	echo 'setting rofi to work for dmenu'
	sudo ln -sf /usr/bin/rofi /usr/bin/dmenu
else
	echo 'Browser and Search engine not installed.'
fi


security=$(dialog --stdout --inputbox "Install Clamav and UFW? [y/N]" 0 0) || exit 1
if [[ $security =~ y ]]
then
	        sudo sh $LINKDOT/installation_scripts/security.sh
else 
	echo "Clamav and UFW not installed."
fi

echo "system installed and configured. if there were any errors please try and run the script again. if that still doesn't help, report the issues at the github! otherwise, reboot and enjoy!"
