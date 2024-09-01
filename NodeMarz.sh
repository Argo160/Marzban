#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    clear
    echo "You should run this script with root!"
    echo "Use sudo -i to change user to root"
    exit 1
fi

function main_menu {
    clear
    cd
    read -p "Are you ready to setup the Node? (y/n): " pp
    # Convert input to lowercase
    pp_lowercase=$(echo "$pp" | tr '[:upper:]' '[:lower:]')
    # Check if the input is "y"
    if [ "$pp_lowercase" = "y" ]; then
        apt-get update && apt-get upgrade -y && apt-get install -y curl socat unzip git
        echo -e "\e[32mSystem Updated and Upgraded and Curl+Socat+git+Unzip Installed.\e[0m"  # Green color for UP
        curl -fsSL https://raw.githubusercontent.com/manageitir/docker/main/install-ubuntu.sh | sh
        echo -e "\e[32mDocker Installed Successfully.\e[0m"  # Green color for UP
        git clone https://github.com/Gozargah/Marzban-node
        mkdir /var/lib/marzban-node
        echo -e "\e[32mMarzban-Node Cloned Successfully.\e[0m"  # Green color for UP
        sleep 5
        clear
        echo -e "\e[32mDo you wish to installe xray version 1.8.20? (y/n)\e[0m"  # Green color for UP
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
