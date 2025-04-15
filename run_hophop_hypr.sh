#!/bin/bash

# Print the logo
print_logo() {
    cat << "EOF"
                                                                                                                                                                                                                             
  ,---,                          ,---,                                  ,---,                                  
,--.' |              ,-.----.  ,--.' |              ,-.----.          ,--.' |              ,-.----.            
|  |  :       ,---.  \    /  \ |  |  :       ,---.  \    /  \         |  |  :              \    /  \   __  ,-. 
:  :  :      '   ,'\ |   :    |:  :  :      '   ,'\ |   :    |        :  :  :              |   :    |,' ,'/ /| 
:  |  |,--. /   /   ||   | .\ ::  |  |,--. /   /   ||   | .\ :        :  |  |,--.     .--, |   | .\ :'  | |' | 
|  :  '   |.   ; ,. :.   : |: ||  :  '   |.   ; ,. :.   : |: |        |  :  '   |   /_ ./| .   : |: ||  |   ,' 
|  |   /' :'   | |: :|   |  \ :|  |   /' :'   | |: :|   |  \ :        |  |   /' :, ' , ' : |   |  \ :'  :  /   
'  :  | | |'   | .; :|   : .  |'  :  | | |'   | .; :|   : .  |        '  :  | | /___/ \: | |   : .  ||  | '    
|  |  ' | :|   :    |:     |`-'|  |  ' | :|   :    |:     |`-'        |  |  ' | :.  \  ' | :     |`-';  : |    
|  :  :_:,' \   \  / :   : :   |  :  :_:,' \   \  / :   : :           |  :  :_:,' \  ;   : :   : :   |  , ;    
|  | ,'      `----'  |   | :   |  | ,'      `----'  |   | :           |  | ,'      \  \  ; |   | :    ---'     
`--''                `---'.|   `--''                `---'.|           `--''         :  \  \`---'.|             
                       `---`                          `---`                          \  ' ;  `---`             
                                                                                      `--`                                                                                        
   
EOF
}

# Clear screen and show logo
clear
print_logo

# Exit on any error
set -e

# Source utility functions
source utils.sh

# Source the package list
if [ ! -f "packages.conf" ]; then
  echo "Error: packages.conf not found!"
  exit 1
fi

source packages.conf

echo "Starting system setup..."

# Update the system first
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Install yay AUR helper if not present
if ! command -v yay &> /dev/null; then
  echo "Installing yay AUR helper..."
  sudo pacman -S --needed git base-devel --noconfirm
  git clone https://aur.archlinux.org/yay.git
  cd yay
  echo "building yay..."
  makepkg -si --noconfirm
  cd ..
  rm -rf yay
else
  echo "yay is already installed"
fi

# Install packages by category
echo "Installing system utilities..."
install_packages "${SYSTEM_UTILS[@]}"

echo "Installing basic tools..."
install_packages "${TOOLS_BASIC[@]}"

echo "Installing extra tools..."
install_packages "${TOOLS_EXTRA[@]}"

echo "Installing fonts..."
install_packages "${FONTS[@]}"

echo "Installing Hyprland packages..."
install_packages "${HYPRLAND[@]}"

echo "Installing gaming stuff..."
install_packages "${GAMING[@]}"

# Enable services
echo "Configuring services..."
for service in "${SERVICES[@]}"; do
  if ! systemctl is-enabled "$service" &> /dev/null; then
    echo "Enabling $service..."
    sudo systemctl enable "$service"
  else
    echo "$service is already enabled"
  fi
done

echo "Setup complete! You may want to reboot your system."
