#!/usr/bin/env bash

set -e

export DB_NAME=testDB
export DB_USER=vipin
export DB_PASSWORD=vipin@123
export GIT_USER=vipin0
export REPO_NAME=php-app

# colors 
Color_Off='\033[0m'       # Text Reset
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green

# cheking os type
# if grep -i 'ID_LIKE' /etc/*release | grep -q -i 'debian';
if grep -i -q 'debian' /etc/*release ;
then
    export CURRENT_OS='Debian'
# elif grep -i 'ID_LIKE' /etc/*release | grep -q -i 'rhel\|centos\|fedora';
elif grep -i -q 'rhel\|centos\|fedora' /etc/*release;
then 
    export CURRENT_OS='RedHat'
fi

# echo $CURRENT_OS

# usage function
usage(){
    echo -e "\nUsege : $(basename $0) [--install, --start, --status, --stop]\n"
    echo -e "Description:\n"
    echo -e "This script allow you to install, start, stop and check status of LAMP stack and run the sample application.\n"
    echo -e "Parameters : \n"
    echo -e "--install\tInstall the LAMP stack."
    echo -e "--start\tStart the LAMP stack, it will install if LAMP is not already installed and start the application."
    echo -e "--status\tCheck status of LAMP stack."
    echo -e "--stop\tStop the LAMP stack."
    echo -e "--help\tTo view this help menu."
    echo -e "\n\n"
    exit 1
}


# get php application and run the lamp
start_php_application(){
    if [[ -z "$GIT_USER" ]];
    then
        read -p "GITHUB User not found in ENV. Enter manually : " git_user
        export GIT_USER=git_user
    fi
    if [[ -z "$REPO_NAME" ]];
    then
        read -p "REPO Name not found in ENV. Enter manually : " repo_name
        export REPO_NAME=repo_name
    fi

    rm -r /tmp/$REPO_NAME > /dev/null 2>&1
    git clone https://github.com/$GIT_USER/$REPO_NAME.git /tmp/$REPO_NAME
    mv -f /tmp/$REPO_NAME/* /var/www/html

    echo -e "\n"

    if [[ -z "$DB_SERVER" ]];
    then
        export DB_SERVER=localhost;
    fi
    if [[ -z "$DB_NAME" ]];
    then
        read -p "DB Name not found in ENV. Enter manually : " db_name
        export DB_NAME=db_name
    fi
    if [[ -z "$DB_USER" ]];
    then
        read -p "DB User not found in ENV. Enter manually : " user
        export DB_USER=user;
    fi
    if [[ -z "$DB_PASSWORD" ]];
    then
        read -p "DB Password not found in ENV. Enter manually : " pass
        export DB_PASSWORD=pass;
    fi 

}

show_ip(){
    echo "Application Started at : "
    internal_ip=$(hostname -I)
    echo "Internal IP : $internal_ip"

    # external ip
    external_ip=$(curl -s ifconfig.me)
    echo "External IP : $external_ip"
}

# install lamp in debian
lamp_install_debian(){
        # echo "Debian"
        apt update -y > /dev/null 2>&1 
        
        echo -e "Installing Apache..."
        apt install apache2 -y > /dev/null 2>&1 && echo "Success" || echo "Failed"
        
        # allowing apache2 in firewall

        chown -R www-data:www-data /var/www/html

        echo "Allowing through firewall..."
        
        ufw allow in "Apache" > /dev/null 2>&1 && echo "Success" || echo "Failed!!"

        echo -e "Installing MySQL..."
        apt install mysql-server -y > /dev/null 2>&1 && echo "Success !! Please run \'mysql_secure_installation\' to configure." || echo "Failed"
        
        echo -e "Installing PHP..."
        apt install -y php libapache2-mod-php php-mysql php-mbstring > /dev/null 2>&1 && echo "Success" || echo "Failed"

}
lamp_install_rhel(){
        # echo "RedHat"
        yum update -y > /dev/null 2>&1
        echo -e "Installing Apache..."
        yum install httpd -y > /dev/null 2>&1 && echo "Success" || echo "Failed"
        
        # allowing http from firewall
        yum install firewall-cmd -y > /dev/null 2>&1
        systemctl start filewalld > /dev/null 2>&1

        echo "Allowing though firewall ... "
        firewall-cmd --permanent --add-service=http >/dev/null 2>&1 && echo "Success" || echo "Failed"
        echo
        echo -e "Installing MySQL..."
        yum install @mysql -y> /dev/null 2>&1 && echo "Success !! Please run \'mysql_secure_installation\' to configure." || echo "Failed"
        echo
        echo -e "Installing PHP..."
        yum install -y php php-mysqlnd php-mbstring php-opcache php-gd > /dev/null 2>&1 && echo "Success" || echo "Failed"
        echo
        # systemctl enable httpd
}

lamp_start(){
    service_path=/lib/systemd/system
    echo -e "$Green Starting LAMP stack.$Color_Off\n";    
    if [[ "$CURRENT_OS" == RedHat ]];
    then
        if [[ ! -e "$service_path/httpd.service" ]] || [[ ! -e "$service_path/mysqld.service" ]];
        then
            echo -e "LAMP installation not found.!!\n"
            lamp_install_rhel
            echo -e "\n **** installation completed *****\n"
        fi
        echo -e "Starting Apache..."
        systemctl start httpd > /dev/null 2>&1 && echo "Started" || echo "Failed"
        echo -e "Starting MySQL..."
        systemctl start mariadb > /dev/null 2>&1 && echo "Started" || echo "Failed"
    elif [[ "$CURRENT_OS" == Debian ]];
    then
        if [[ ! -e "$service_path/apache2.service" ]] || [[ ! -e "$service_path/mysql.service" ]];
        then
            echo -e "LAMP installation not found.!!\n"
            lamp_install_debian
            echo -e "\n **** installation completed *****\n"
        fi
        echo -e "Starting Apache..."
        systemctl start apache2 > /dev/null 2>&1 && echo "Started" || echo "Failed"
        echo -e "Starting MySQL..."
        systemctl start mysql > /dev/null 2>&1 && echo "Started" || echo "Failed"
    fi
    
}
lamp_stop(){
    echo -e "$Green Stoping LAMP stack.$Color_Off\n";

    if [[ "$CURRENT_OS" == RedHat ]];
    then
        echo "Stopping Apache..."
        systemctl stop httpd > /dev/null 2>&1 && echo "stopped" || echo "Failed"
        echo "Stopping MySQL..."
        systemctl stop mariadb > /dev/null 2>&1 && echo "stopped" || echo "Failed"

    elif [[ "$CURRENT_OS" == Debian ]];
    then
        echo "Stopping Apache..."
        systemctl stop apache2 > /dev/null 2>&1 && echo "Started" || echo "Failed"
        echo "Stopping MySQL..."
        systemctl stop mysql > /dev/null 2>&1 && echo "stopped" || echo "Failed"
    
    fi
}

print_status(){
    (grep -q -w "active" $1 && echo "Running") \
        || (grep -q -w "inactive" $1 && echo "Stopped") 
    grep -q -w "failed" $1 && echo "Failed !!. Please check manually." 
}
lamp_status(){
    echo -e "$Green Status of LAMP stack $Color_Off\n"

    if [[ "$CURRENT_OS" == RedHat ]];
    then
        echo "Apache ... "
        systemctl status httpd > /tmp/httpd_status
        print_status /tmp/httpd_status

        echo -e "\nMySQL ... "
        systemctl status mysql > /tmp/mysql_status
        print_status /tmp/mysql_status

        rm /tmp/httpd_status /tmp/mysql_status

    elif [[ "$CURRENT_OS" == Debian ]];
    then
         echo "Apache ... "
        systemctl status apache2 > /tmp/httpd_status
        print_status /tmp/httpd_status

        echo -e "\nMySQL ... "
        systemctl status mysql > /tmp/mysql_status
        print_status /tmp/mysql_status

        rm /tmp/httpd_status /tmp/mysql_status
    fi

}

lamp_install(){
    if [[ "$CURRENT_OS" == RedHat ]];
    then
        lamp_install_rhel
    elif [[ "$CURRENT_OS" == Debian ]];
    then
        lamp_install_debian
    fi
}
# forcing script to run as root
if [[ "$EUID" -ne 0 ]];
then
    echo -e "$Red Error : Please use \'sudo\' to run the script.$Color_Off" 1>&2
    exit 100
fi

# validating number of input
if ! [[ $# -eq 1 ]];
then
echo "Invalid number of arguments given."
    usage
fi

# validating and getting correct options
while [[ $# -eq 1 ]]
do
    case "$1" in
    --install)
       lamp_install
        ;;
    --start)
       start_php_application  # starting php application
       lamp_start  # starting lamp
       echo 
       show_ip  # showing ip
        ;;
    --status)
       lamp_status
        ;;
    --stop)
       lamp_stop
        ;;
    --help|*)
        echo -e "Invalid option given."
        usage
        ;;
    esac
    shift
done

# CREATE USER 'vipin'@'localhost' IDENTIFIED BY 'vipin@123';
# GRANT ALL PRIVILEGES ON * . * TO 'vipin'@'localhost';
