#!/usr/bin/env bash

clear

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BLUE}${BOLD}Kitty Terminal Setup Script${NC}"
echo ""
echo -e "${CYAN}Setting up kitty-tabs by monoira (https://github.com/monoira/kitty-tabs)${NC}"
echo ""

detect_package_manager() {
    if command -v apt &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v emerge &> /dev/null; then
        echo "emerge"
    elif command -v zypper &> /dev/null; then
        echo "zypper"
    elif command -v apk &> /dev/null; then
        echo "apk"
    elif command -v nix-env &> /dev/null; then
        echo "nix"
    elif command -v xbps-install &> /dev/null; then
        echo "xbps"
    elif command -v brew &> /dev/null; then
        echo "brew"
    elif command -v pkg &> /dev/null; then
        echo "pkg"
    elif command -v port &> /dev/null; then
        echo "port"
    else
        echo "unknown"
    fi
}

install_package() {
    local pkg_name=$1
    local pkg_manager=$(detect_package_manager)
    
    echo -e "${CYAN}▶ Installing ${BOLD}$pkg_name${NC}${CYAN} using $pkg_manager...${NC}"
    
    case $pkg_manager in
        apt)
            sudo apt update && sudo apt install -y $pkg_name
            ;;
        dnf)
            sudo dnf install -y $pkg_name
            ;;
        yum)
            sudo yum install -y $pkg_name
            ;;
        pacman)
            sudo pacman -Sy --noconfirm $pkg_name
            ;;
        emerge)
            sudo emerge --ask=n $pkg_name
            ;;
        zypper)
            sudo zypper install -y $pkg_name
            ;;
        apk)
            sudo apk add $pkg_name
            ;;
        nix)
            nix-env -iA nixpkgs.$pkg_name
            ;;
        xbps)
            sudo xbps-install -y $pkg_name
            ;;
        brew)
            brew install $pkg_name
            ;;
        pkg)
            sudo pkg install -y $pkg_name
            ;;
        port)
            sudo port install $pkg_name
            ;;
        *)
            echo -e "${RED}⚠️ Unsupported package manager. Please install $pkg_name manually.${NC}"
            read -p "Press Enter to continue after installing $pkg_name, or Ctrl+C to abort..."
            return 1
            ;;
    esac
    
    return $?
}

install_kitty() {
    local pkg_manager=$(detect_package_manager)
    
    case $pkg_manager in
        apt|dnf|yum|zypper|apk|pkg|port)
            install_package kitty
            ;;
        pacman)
            install_package kitty
            ;;
        emerge)
            sudo emerge --ask=n x11-terms/kitty
            ;;
        nix)
            nix-env -iA nixpkgs.kitty
            ;;
        xbps)
            sudo xbps-install -y kitty
            ;;
        brew)
            brew install --cask kitty
            ;;
        *)
            echo -e "${YELLOW}⚠️ Unsupported package manager for kitty installation.${NC}"
            echo -e "${YELLOW}Please install kitty manually from https://sw.kovidgoyal.net/kitty/binary/${NC}"
            read -p "Press Enter to continue after installing kitty, or Ctrl+C to abort..."
            ;;
    esac
    
    return $?
}

install_unzip() {
    local pkg_manager=$(detect_package_manager)
    
    case $pkg_manager in
        apt|dnf|yum|pacman|zypper|apk|xbps|pkg|port)
            install_package unzip
            ;;
        emerge)
            sudo emerge --ask=n app-arch/unzip
            ;;
        nix)
            nix-env -iA nixpkgs.unzip
            ;;
        brew)
            brew install unzip
            ;;
        *)
            echo -e "${YELLOW}⚠️ Unsupported package manager for automatic unzip installation.${NC}"
            echo -e "${YELLOW}Please install unzip manually.${NC}"
            read -p "Press Enter to continue after manually installing unzip, or Ctrl+C to abort..."
            ;;
    esac
    
    return $?
}

install_git_if_needed() {
    if ! command -v git &> /dev/null; then
        echo -e "${YELLOW}⚠️ Git is not installed. Installing git...${NC}"
        local pkg_manager=$(detect_package_manager)
        
        case $pkg_manager in
            apt|dnf|yum|pacman|zypper|apk|xbps|pkg|port)
                install_package git
                ;;
            emerge)
                sudo emerge --ask=n dev-vcs/git
                ;;
            nix)
                nix-env -iA nixpkgs.git
                ;;
            brew)
                brew install git
                ;;
            *)
                echo -e "${RED}⚠️ Unsupported package manager for git installation.${NC}"
                echo -e "${YELLOW}Please install git manually.${NC}"
                read -p "Press Enter to continue after manually installing git, or Ctrl+C to abort..."
                ;;
        esac
    fi
}

command_exists() {
    command -v "$1" &> /dev/null
}

create_dir_if_not_exists() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo -e "${GREEN}✓ Created directory: $1${NC}"
    fi
}

pkg_manager=$(detect_package_manager)
echo -e "${PURPLE}🔍 Detected package manager: ${BOLD}$pkg_manager${NC}"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo -e "${PURPLE}🔍 Detected distribution: ${BOLD}$NAME${NC}"
elif [ -f /etc/gentoo-release ]; then
    echo -e "${PURPLE}🔍 Detected distribution: ${BOLD}Gentoo${NC}"
elif [ -f /etc/nixos/configuration.nix ]; then
    echo -e "${PURPLE}🔍 Detected distribution: ${BOLD}NixOS${NC}"
else
    echo -e "${YELLOW}⚠️ Could not determine distribution.${NC}"
fi
echo ""

install_git_if_needed

if ! command_exists kitty; then
    echo -e "${YELLOW}⚠️ Kitty terminal is not installed. Installing kitty...${NC}"
    install_kitty
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to install kitty automatically.${NC}"
        echo -e "${YELLOW}Please install kitty manually from https://sw.kovidgoyal.net/kitty/binary/${NC}"
        read -p "Press Enter to continue after manually installing kitty, or Ctrl+C to abort..."
    else
        echo -e "${GREEN}✓ Kitty terminal has been installed successfully.${NC}"
    fi
else
    echo -e "${GREEN}✓ Kitty terminal is already installed.${NC}"
fi
echo ""

read -rp "$(echo -e ${CYAN}Do you want to install Hack Nerd Font? \(recommended for the theme\) [y/N]: ${NC})" install_font
if [[ $install_font =~ ^[Yy]$ ]]; then
    if ! command_exists unzip; then
        echo -e "${YELLOW}⚠️ Unzip is not installed. Installing unzip...${NC}"
        install_unzip
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to install unzip automatically.${NC}"
            echo -e "${YELLOW}Please install unzip manually.${NC}"
            read -p "Press Enter to continue after manually installing unzip, or Ctrl+C to abort..."
        fi
    fi
    
    tmp_dir="/tmp/hack-nerd-font"
    create_dir_if_not_exists "$tmp_dir"
    
    echo -e "${CYAN}▶ Downloading Hack Nerd Font...${NC}"
    if command_exists curl; then
        curl -L -o "$tmp_dir/Hack.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip"
    elif command_exists wget; then
        wget -O "$tmp_dir/Hack.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip"
    else
        echo -e "${RED}Neither curl nor wget is installed. Please install one of them.${NC}"
        read -p "Press Enter to continue after manually installing curl or wget, or Ctrl+C to abort..."
        exit 1
    fi
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to download Hack Nerd Font. Please check your internet connection and try again.${NC}"
        exit 1
    fi
    
    echo -e "${CYAN}▶ Extracting Hack Nerd Font...${NC}"
    unzip -o "$tmp_dir/Hack.zip" -d "$tmp_dir"
    
    if [ -d "$HOME/.local/share/fonts" ]; then
        font_dir="$HOME/.local/share/fonts"
    elif [ -d "/usr/local/share/fonts" ] && [ -w "/usr/local/share/fonts" ]; then
        font_dir="/usr/local/share/fonts"
    elif [ -d "/usr/share/fonts" ] && [ -w "/usr/share/fonts" ]; then
        font_dir="/usr/share/fonts"
    else
        font_dir="$HOME/.fonts"
    fi
    
    create_dir_if_not_exists "$font_dir"
    
    echo -e "${CYAN}▶ Installing Hack Nerd Font to $font_dir...${NC}"
    cp "$tmp_dir"/*.ttf "$font_dir/" 2>/dev/null
    cp "$tmp_dir"/*.otf "$font_dir/" 2>/dev/null
    
    echo -e "${CYAN}▶ Updating font cache...${NC}"
    if command_exists fc-cache; then
        fc-cache -vf
    else
        echo -e "${YELLOW}⚠️ Warning: fc-cache not found. You may need to update your font cache manually.${NC}"
    fi
    
    echo -e "${GREEN}✓ Hack Nerd Font has been installed successfully.${NC}"
    
    rm -rf "$tmp_dir"
    echo ""
fi

echo -e "${CYAN}▶ Cloning the kitty-tabs repository...${NC}"
git_tmp_dir="/tmp/kitty-tabs"
rm -rf "$git_tmp_dir" 
git clone "https://github.com/monoira/kitty-tabs" "$git_tmp_dir"

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to clone the kitty-tabs repository. Please check your internet connection and try again.${NC}"
    exit 1
fi

kitty_config_dir="$HOME/.config/kitty"
if [ -d "$kitty_config_dir" ]; then
    echo -e "${PURPLE}🔍 Kitty configuration directory found at $kitty_config_dir.${NC}"
    
    read -rp "$(echo -e ${CYAN}Do you want to backup the existing kitty configuration? [Y/n]: ${NC})" backup_config
    if [[ ! $backup_config =~ ^[Nn]$ ]]; then
        backup_dir="$kitty_config_dir.backup.$(date +%Y%m%d%H%M%S)"
        echo -e "${CYAN}▶ Backing up existing configuration to $backup_dir...${NC}"
        cp -r "$kitty_config_dir" "$backup_dir"
        echo -e "${GREEN}✓ Backup completed.${NC}"
    fi
else
    create_dir_if_not_exists "$kitty_config_dir"
fi

echo -e "${CYAN}▶ Installing kitty-tabs configuration...${NC}"
cp -r "$git_tmp_dir"/* "$kitty_config_dir/"

rm -rf "$git_tmp_dir"

echo -e "${GREEN}${BOLD}Success${NC}"
echo ""
echo -e "${CYAN}Thank you for using this setup script!${NC}"
echo -e "${CYAN}kitty-tabs configuration by monoira: https://github.com/monoira/kitty-tabs${NC}"
echo -e "${YELLOW}Please restart kitty terminal to apply the new configuration.${NC}"
