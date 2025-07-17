#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    clear
    echo "You should run this script with root!"
    echo "Use sudo -i to change user to root"
    exit 1
fi

# Declare Paths & Settings.
ENV_FILE="/root/ac-backup-m/opt/marzban/.env"
SQL_BACKUP_ADDRESS="/root/ac-backup-m.zip/var/lib/marzban/mysql/db-backup/marzban.sql"

function main_menu {
    clear
    cd
    read -p "Are you ready to setup New Panel With Backup? (y/n): " pp
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
        nohup sudo bash -c "$(curl -sL https://github.com/Gozargah/Marzban-scripts/raw/master/marzban.sh)" @ install > /dev/null 2>&1 &
        clear
        echo -e "\e[32mCreating marzban Admin:(Usernam/Password)\e[0m"  # Green color for UP
        marzban cli admin create --sudo
        cd
        mkdir -p "ac-backup-m"
        unzip ac-backup-m.zip -d "ac-backup-m"
        cp -r /root/ac-backup-m/opt/marzban /opt/
        cp -r /root/ac-backup-m/opt/marzban/.env /opt/marzban/
        cp -r /root/ac-backup-m/var/lib/marzban /var/lib/
        marzban restart
        DB_PASSWORD=$(grep '^MYSQL_ROOT_PASSWORD=' "$ENV_FILE" | cut -d'=' -f2)
        docker exec -i marzban-mysql-1 mysql -u root -p"$DB_PASSWORD" marzban < "$SQL_BACKUP_ADDRESS"
        marzban restart
    fi
}
main_menu
