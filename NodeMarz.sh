#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    clear
    echo "You should run this script with root!"
    echo "Use sudo -i to change user to root"
    exit 1
fi

# Declare Paths & Settings.
SYS_PATH="/etc/sysctl.conf"
PROF_PATH="/etc/profile"
SSH_PORT=""
SSH_PATH="/etc/ssh/sshd_config"
SWAP_PATH="/swapfile"
SWAP_SIZE=2G

function main_menu {
    clear
    cd
    read -p "Are you ready to setup the Node? (y/n): " pp
    # Convert input to lowercase
    pp_lowercase=$(echo "$pp" | tr '[:upper:]' '[:lower:]')
    # Check if the input is "y"
    if [ "$pp_lowercase" = "y" ]; then
        apt-get update && apt-get upgrade -y
        echo
        echo -e "\e[32mSystem Updated and Upgraded.\e[0m"  # Green color for UP
        echo
        sleep 0.5
        echo -e "\033[33mInstalling Curl...\033[0m" #yellow Color
        apt-get install -y curl
        if command -v curl > /dev/null; then
            echo
            echo -e "\e[32mCurl Installed.\e[0m"  # Green color for UP
            echo
            sleep 0.5
        else
            echo
            echo -e "\033[31mCurl is not installed.\033[0m"  # Print in red
            echo
            sleep 0.5
        fi
        
        echo
        echo -e "\033[33mInstalling socat...\033[0m" #yellow Color
        echo
        sleep 0.5
        apt-get install -y socat
        if command -v socat > /dev/null; then
            echo
            echo -e "\e[32msocat Installed.\e[0m"  # Green color for UP
            echo
            sleep 0.5
        else
            echo
            echo -e "\033[31msocat is not installed.\033[0m"  # Print in red
            echo
            sleep 0.5
        fi

        echo
        echo -e "\033[33mInstalling unzip...\033[0m" #yellow Color
        apt-get install -y unzip
        if command -v unzip > /dev/null; then
            echo
            echo -e "\e[32munzip Installed.\e[0m"  # Green color for UP
            echo
            sleep 0.5
        else
            echo
            echo -e "\033[31munzip is not installed.\033[0m"  # Print in red
            echo
            sleep 0.5
        fi

        echo
        echo -e "\033[33mInstalling git...\033[0m" #yellow Color
        apt-get install -y git
        if command -v git > /dev/null; then
            echo
            echo -e "\e[32mgit Installed.\e[0m"  # Green color for UP
            echo
            sleep 0.5
        else
            echo
            echo -e "\033[31mgit is not installed.\033[0m"  # Print in red
            echo
            sleep 0.5
        fi

        echo
        echo -e "\033[33mInstalling Docker...\033[0m" #yellow Color
        curl -fsSL https://raw.githubusercontent.com/manageitir/docker/main/install-ubuntu.sh | sh
        if command -v docker > /dev/null; then
            echo
            echo -e "\e[32mdocker Installed.\e[0m"  # Green color for UP
            echo
            sleep 0.5
        else
            echo
            echo -e "\033[31mdocker is not installed.\033[0m"  # Print in red
            echo
            sleep 0.5
        fi        

        ## Make Swap
        sudo fallocate -l $SWAP_SIZE $SWAP_PATH  ## Allocate size
        sudo chmod 600 $SWAP_PATH                ## Set proper permission
        sudo mkswap $SWAP_PATH                   ## Setup swap         
        sudo swapon $SWAP_PATH                   ## Enable swap
        echo "$SWAP_PATH   none    swap    sw    0   0" >> /etc/fstab ## Add to fstab
        echo 
        green_msg 'SWAP Created Successfully.'
        echo -e "\e[32mdSWAP Created Successfully.\n\e[0m"  # Green color for UP
        echo
        sleep 0.5

        git clone https://github.com/Gozargah/Marzban-node
        mkdir /var/lib/marzban-node
        echo
        echo -e "\e[32mMarzban-Node Cloned Successfully.\e[0m"  # Green color for UP
        sleep 1

        mkdir -p /var/lib/marzban/assets/
        wget -O /var/lib/marzban/assets/geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat
        wget -O /var/lib/marzban/assets/geoip.dat https://github.com/v2fly/geoip/releases/latest/download/geoip.dat
        wget -O /var/lib/marzban/assets/iran.dat https://github.com/bootmortis/iran-hosted-domains/releases/latest/download/iran.dat
        
        
        clear
        echo -e "\e[32mDo you wish to install xray version 1.8.24? (y/n)\e[0m"  # Green color for UP
        read -p "Y = Version 1.8.24 | N = Current Version: " ver
        # Convert input to lowercase
        ver_lowercase=$(echo "$ver" | tr '[:upper:]' '[:lower:]')
        # Check if the input is "y"
        if [ "$ver_lowercase" = "y" ]; then
            cd
            mkdir -p /var/lib/marzban/xray-core && cd /var/lib/marzban/xray-core
            wget https://github.com/XTLS/Xray-core/releases/download/v1.8.24/Xray-linux-64.zip
            unzip Xray-linux-64.zip
            rm Xray-linux-64.zip
            cd ~/Marzban-node
            curl -o docker-compose.yml https://raw.githubusercontent.com/Argo160/Marzban/main/doc1.8.20.yml
        else
            cd ~/Marzban-node
            curl -o docker-compose.yml https://raw.githubusercontent.com/Argo160/Marzban/main/docCurrent.yml
        fi

        # Define the file path where the certificate will be saved
        CERT_FILE="/var/lib/marzban-node/ssl_client_cert.pem"

        # Prompt the user to input the certificate
        echo "Please paste the certificate below, then press Enter twice:"

        # Read the certificate content into a variable
        CERT_CONTENT=""
        while IFS= read -r line; do
            # Break the loop if the user presses Enter twice (empty line)
            [ -z "$line" ] && break
            CERT_CONTENT="${CERT_CONTENT}${line}\n"
        done

        # Save the certificate content to the file
        echo -e "$CERT_CONTENT" | sudo tee "$CERT_FILE" > /dev/null

        # Confirm the certificate was saved
        if [ -f "$CERT_FILE" ]; then
            echo "Certificate saved to $CERT_FILE"
        else
            echo "Failed to save the certificate."
            exit 1
        fi

        docker compose up -d
        sleep 1
   
        read -p "Reboot now? (Recommended) (y/n)" reb
        echo 
        while true; do
            echo 
            if [[ "$reb" == 'y' || "$reb" == 'Y' ]]; then
                sleep 0.5
                reboot
                exit 0
            fi
            if [[ "$reb" == 'n' || "$reb" == 'N' ]]; then
                break
            fi
        done    
    
    
    fi
}
main_menu
