#!/bin/bash

# kali_setup.sh

# Set up logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$HOME/Desktop/kali_setup_log.txt"
DRY_RUN=false

# Colors for terminal output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function for logging
log() {
    local level="$1"
    local message="$2"
    local color=""
    case $level in
    "INFO") color="$GREEN" ;;
    "WARN") color="$YELLOW" ;;
    "ERROR") color="$RED" ;;
    esac
    echo -e "${color}[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message${NC}" | tee -a "$LOG_FILE"
}

# Array to store errors
errors=()

# Function to execute or simulate command
execute() {
    if [ "$DRY_RUN" = true ]; then
        log "INFO" "[DRY RUN] Would execute: $*"
    else
        log "INFO" "Executing: $*"
        eval "$@"
        exit_status=$?
        if [ $exit_status -ne 0 ]; then
            error_msg="Command failed with exit status $exit_status: $*"
            log "ERROR" "$error_msg"
            errors+=("$error_msg")
        fi
    fi
}

# Function to execute or simulate command with automatic yes
execute_auto_yes() {
    if [ "$DRY_RUN" = true ]; then
        log "INFO" "[DRY RUN] Would execute: yes | $*"
    else
        log "INFO" "Executing with auto yes: $*"
        yes | eval "$@"
        exit_status=$?
        if [ $exit_status -ne 0 ]; then
            error_msg="Command failed with exit status $exit_status: yes | $*"
            log "ERROR" "$error_msg"
            errors+=("$error_msg")
        fi
    fi
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
    --dry-run) DRY_RUN=true ;;
    *)
        echo "Unknown parameter passed: $1"
        exit 1
        ;;
    esac
    shift
done

log "INFO" "Starting Kali setup script"

# Update the system
log "INFO" "=== System Update ==="
execute sudo apt update

# Install packages
log "INFO" "=== Package Installation ==="
execute sudo apt install -y \
    emacs \
    eza \
    alacritty \
    git \
    bat

#Install docker
log "INFO" "=== Docker-ce Installation ==="
execute echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" |
    sudo tee /etc/apt/sources.list.d/docker.list
#import gpg
execute curl -fsSL https://download.docker.com/linux/debian/gpg |
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
execute sudo apt update
execute sudo apt install -y docker-ce docker-ce-cli containerd.io

# Install Starship
log "INFO" "=== Installing Starship ==="
execute_auto_yes curl -sS https://starship.rs/install.sh | sh

# Install oh-my-zsh
log "INFO" "=== Installing oh-my-zsh ==="
execute_auto_yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install zsh plugins
log "INFO" "=== Installing zsh plugins ==="
execute git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
execute git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
execute git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/fast-syntax-highlighting
execute git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ~/.oh-my-zsh/plugins/zsh-autocomplete

# Install tmuxinator
log "INFO" "=== Installing tmuxinator ==="
execute sudo gem install tmuxinator

# Install doom emacs
log "INFO" "=== Installing Doom Emacs ==="
execute git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
execute_auto_yes ~/.emacs.d/bin/doom install

# Clone dotfiles repo
log "INFO" "=== Cloning dotfiles repository ==="
execute git clone https://github.com/bloodstiller/kaliconfigs.git ~/.dotfiles

# Setup dotfiles
log "INFO" "=== Setting up dotfiles ==="
execute mkdir -p ~/.doom.d
execute rm -rf ~/.zshrc ~/.doom.d/* ~/.config/starship.toml ~/.config/alacritty.yml
execute ln -s ~/.dotfiles/Zsh/.zshrc ~/.zshrc
execute ln -s ~/.dotfiles/Doom/config.el ~/.doom.d/config.el
execute ln -s ~/.dotfiles/Doom/init.el ~/.doom.d/init.el
execute ln -s ~/.dotfiles/Doom/packages.el ~/.doom.d/packages.el
execute ln -s ~/.dotfiles/Doom/README.org ~/.doom.d/README.org
execute ln -s ~/.dotfiles/Starship/starship.toml ~/.config/starship.toml
execute ln -s ~/.dotfiles/Alacritty ~/.config/Alacritty
execute ln -s ~/.dotfiles/Tmux/.tmux.conf ~/.tmux.conf

# Installing Docker Enable docker
log "INFO" "=== Enabling Docker ==="
execute sudo systemctl enable docker --now
execute sudo usermod -aG docker $USER

# Build doom packages
log "INFO" "=== Building Doom Emacs packages ==="
execute ~/.emacs.d/bin/doom sync

# Setup mount points and directories
log "INFO" "=== Setting up mount points and directories ==="
execute sudo mkdir -p /mnt/100gb
execute mkdir -p ~/Dropbox

# Mount shared folders & drive
log "INFO" "=== Mounting shared folders and drives ==="
execute sudo mount -t ext4 UUID=89edac1a-7171-4421-87a6-696050f30325 /mnt/100gb

# Update fstab
log "INFO" "=== Updating fstab ==="
execute echo "host_share /home/kali/host_share 9p trans=virtio,_netdev 0 0" | sudo tee -a /etc/fstab
execute echo "UUID=89edac1a-7171-4421-87a6-696050f30325	/mnt/100gb	ext4	defaults	0	2" | sudo tee -a /etc/fstab

# Install Dropbox
log "INFO" "=== Installing Dropbox ==="
execute wget https://www.dropbox.com/download?dl=packages/ubuntu/dropbox_2024.04.17_amd64.deb -O $HOME/Desktop/dropbox_2024.04.17_amd64.deb
execute sudo dpkg -i $HOME/Desktop/dropbox_2024.04.17_amd64.deb
execute sudo apt --fix-broken install -y

# Symlink Dropbox and Wordlists
log "INFO" "=== Setting up Dropbox and Wordlists symlinks ==="
execute sudo ln -s /mnt/100gb/Dropbox/Dropbox $HOME/Dropbox
execute sudo ln -s /usr/share/wordlists ~/wordlists

# Clean up
log "INFO" "=== Cleaning up ==="
execute sudo apt autoremove -y
execute sudo apt clean

log "INFO" "=== Setup Finished ==="
log "INFO" "Setup complete!"
log "INFO" "Finish setup of Dropbox in GUI"
log "INFO" "Remember to logout & back in for docker user to be enabled"

if [ ${#errors[@]} -ne 0 ]; then
    log "WARN" "The following errors occurred during setup:"
    for error in "${errors[@]}"; do
        log "WARN" "  - $error"
    done
else
    log "INFO" "Setup completed successfully with no errors."
fi
