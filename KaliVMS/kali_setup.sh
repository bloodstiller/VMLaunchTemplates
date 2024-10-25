#!/bin/bash

# kali_setup.sh

# Mount the shared folder
sudo mkdir -p /mnt/host_setup
sudo mount -t 9p -o trans=virtio host_setup /mnt/host_setup

# Mount the SSH key directory
sudo mkdir -p /mnt/host_ssh
sudo mount -t 9p -o trans=virtio host_ssh /mnt/host_ssh

# Copy the SSH key
SSH_KEY_NAME=$(basename "$SSH_KEY_PATH")
mkdir -p ~/.ssh
cp /mnt/host_ssh/"$SSH_KEY_NAME" ~/.ssh/
chmod 600 ~/.ssh/"$SSH_KEY_NAME"

# Add the key to ssh-agent
eval $(ssh-agent -s)
ssh-add ~/.ssh/"$SSH_KEY_NAME"

# Unmount the SSH key directory
sudo umount /mnt/host_ssh

# Update the system
sudo apt update

# Install packages
sudo apt install -y \
    docker.io \
    emacs \
    eza \
    alacritty \
    git \
    bat

# Install Starship
curl -sS https://starship.rs/install.sh | sh

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# make zsh default
chsh -s $(which zsh)

# Install zsh plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete

# Install tmuxinator
gem install tmuxinator

# Install Dropbox
wget https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2024.04.17_amd64.deb
sudo dpkg -i dropbox_2024.04.17_amd64.deb

# Install doom emacs
git clone --depth 1 https://github.com/doomemacs/doom emacs ~/.emacs.d
~/.emacs.d/bin/doom install

# Clone dotfiles repo
git clone https://github.com/bloodstiller/kaliconfigs.git ~/.dotfiles

# Symlink dotfiles
ln -s ~/.dotfiles/Zsh/.zshrc ~/.zshrc
ln -s ~/.dotfiles/Doom/* ~/.doom.d
ln -s ~/.dotfiles/Starship/.config/starship.toml ~/.config/starship.toml
ln -s ~/.dotfiles/Alacritty/.config/alacritty.yml ~/.config/alacritty.yml
ln -s ~/.dotfiles/tmux/.tmux.conf ~/.tmux.conf

sudo systemctl enable docker --now

# Build doom packages
~/.emacs.d/bin/doom sync

# Create mount point for 100gb storage
sudo mkdir -p /mnt/100gb
# Update fstab
echo "UUID=89edac1a-7171-4421-87a6-696050f30325	/mnt/100gb	ext4	defaults	0	2" | sudo tee -a /etc/fstab




# Upgrade packages
sudo apt upgrade -y

# Clean up
sudo apt autoremove -y
sudo apt clean

echo "Setup complete!"
