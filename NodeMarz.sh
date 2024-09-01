#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    clear
    echo "You should run this script with root!"
    echo "Use sudo -i to change user to root"
    exit 1
fi
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
        echo -e "\e[32mSystem Updated and Upgraded.\e[0m"  # Green color for UP
        echo -e "\033[33m\n\nInstalling Curl...\033[0m" #yellow Color
        apt-get install -y curl
        if command -v curl > /dev/null; then
            echo -e "\e[32m\n\nCurl Installed.\e[0m"  # Green color for UP
        else
            echo -e "\033[31mCurl is not installed.\033[0m"  # Print in red
        fi
        
        echo -e "\033[33m\n\nInstalling socat...\033[0m" #yellow Color
        apt-get install -y socat
        if command -v socat > /dev/null; then
            echo -e "\e[32m\n\nsocat Installed.\e[0m"  # Green color for UP
        else
            echo -e "\033[31msocat is not installed.\033[0m"  # Print in red
        fi
        
        echo -e "\033[33m\n\nInstalling unzip...\033[0m" #yellow Color
        apt-get install -y unzip
        if command -v unzip > /dev/null; then
            echo -e "\e[32m\n\nunzip Installed.\e[0m"  # Green color for UP
        else
            echo -e "\033[31munzip is not installed.\033[0m"  # Print in red
        fi

        echo -e "\033[33m\n\nInstalling git...\033[0m" #yellow Color
        apt-get install -y git
        if command -v git > /dev/null; then
            echo -e "\e[32m\n\ngit Installed.\e[0m"  # Green color for UP
        else
            echo -e "\033[31mgit is not installed.\033[0m"  # Print in red
        fi

        echo -e "\033[33m\n\nInstalling Docker...\033[0m" #yellow Color
        curl -fsSL https://raw.githubusercontent.com/manageitir/docker/main/install-ubuntu.sh | sh
        if command -v docker > /dev/null; then
            echo -e "\e[32m\n\ndocker Installed.\e[0m"  # Green color for UP
        else
            echo -e "\033[31mdocker is not installed.\033[0m"  # Print in red
        fi        

        ## Make Swap
        sudo fallocate -l $SWAP_SIZE $SWAP_PATH  ## Allocate size
        sudo chmod 600 $SWAP_PATH                ## Set proper permission
        sudo mkswap $SWAP_PATH                   ## Setup swap         
        sudo swapon $SWAP_PATH                   ## Enable swap
        echo "$SWAP_PATH   none    swap    sw    0   0" >> /etc/fstab ## Add to fstab
        echo 
        green_msg 'SWAP Created Successfully.'
        echo -e "\e[32m\n\ndSWAP Created Successfully.\n\e[0m"  # Green color for UP
        echo
        sleep 0.5

        git clone https://github.com/Gozargah/Marzban-node
        mkdir /var/lib/marzban-node
        echo -e "\e[32mMarzban-Node Cloned Successfully.\e[0m"  # Green color for UP
        sleep 5
        clear
        echo -e "\e[32mDo you wish to install xray version 1.8.20? (y/n)\e[0m"  # Green color for UP
        read -p "Y = Version 1.8.20 | N = Current Version: " ver
        # Convert input to lowercase
        ver_lowercase=$(echo "$ver" | tr '[:upper:]' '[:lower:]')
        # Check if the input is "y"
        if [ "$ver_lowercase" = "y" ]; then
            cd
            mkdir -p /var/lib/marzban/xray-core && cd /var/lib/marzban/xray-core
            wget https://github.com/XTLS/Xray-core/releases/download/v1.8.20/Xray-linux-64.zip
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
        read -n 1 -s -r -p "Press any key to continue"
        echo
    fi
}
main_menu
