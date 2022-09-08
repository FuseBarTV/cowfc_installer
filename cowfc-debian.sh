# CoWFC Installer
# By EnergyCube (Based on beanjr script and the re-written script by kyle95wm)
# Ensure running as root
if [ "$(id -u)" != "0" ]; then
    exec sudo "$0" "$@"
fi
mkdir /var/www
cd /var/www
# Check if we already installed the server
if [ -f /etc/.dwc_installed ]; then
    printf "\033c"
    echo "###############################################################"
    echo -e "##################### \e[0;31m!!!!! WARNING !!!!!\e[0m #####################"
    echo "  You already installed CoWFC. There is no need to re-run it.  "
    echo "        Perhaps some time down the road we can offer an        "
    echo "                       uninstall option.                       "
    echo " If you only want to RESET your dwc server, just delete gpcm.db"
    echo "       and storage.db (don't forget to reboot of course)       "
    echo "  In you want to UPDATE your actual installation, the best way "
    echo "     is to save gpcm.db and storage.db (in dwc network dir)    "
    echo "    nuke your system, re-install everything with this script   "
    echo "               and restore gpcm.db and storage.db              "
    echo "And if you wish to uninstall everything, just nuke your system."
    echo "###############################################################"
    exit 3
fi

# Warning about security
printf "\033c"
echo "###############################################################"
echo -e "##################### \e[0;31m!!!!! WARNING !!!!!\e[0m #####################"
echo "   Wiimmfi has undergone some changes which makes it so that   "
echo "          their servers are more secure from hackers.          "
echo " Having said that, this means that the CoWFC fork will not be  "
echo "        getting the security patch, as it is unclear...        "
echo "  For the time being, you accept that you run your own server  "
echo " with a chance that hackers will be able to execute code over  "
echo "                         the network...                        "
echo "  This might mean that hackers can in theory, brick consoles.  "
echo "###############################################################"

read -rp "Please type ACCEPT to accept the risk: "
if [ "$REPLY" != "ACCEPT" ]; then
    echo "Verification FAILED!"
    exit 2
fi

# We will test internet connectivity using ping
if [ "$1" != "-s" ]; then
    if ping -c 2 github.com >/dev/nul; then
        echo "Internet is OK"
    else
        echo "Internet Connection Test Failed!"
        echo "If you want to bypass internet check use -s arg!"
        exit 4
    fi
else
    echo "Internet check skipped..."
fi

function create_apache_vh_nintendo() {
    printf "\033c"
    echo -e "\e[1;33mCreating Nintendo virtual hosts...\e[1;0m"
    read -p "Please enter your Fully Qualified Domain Name you wish to use: " domain
    if [ -z $domain ]; then
        create_apache_vh_nintendo
    fi

    # This function will create virtual hosts for Nintendo's domains in Apache
    echo "Your domain $domain"
    echo "Will replace nintendowifi.net"
    echo "For example: gamestats2.gs.$domain"
    read -p "Is this correct? [y/n] " confirm

    if [ $confirm == "y" ]; then
        echo "Great! Sit back and relax..."
    else
        create_apache_vh_nintendo
    fi

    echo "Creating custom virtual hosts...."
    touch /etc/apache2/sites-available/gamestats2.gs.$domain.conf
    touch /etc/apache2/sites-available/gamestats.gs.$domain.conf
    touch /etc/apache2/sites-available/nas-naswii-dls1-conntest.$domain.conf
    touch /etc/apache2/sites-available/sake.gs.$domain.conf
    cat >/etc/apache2/sites-available/gamestats2.gs.$domain.conf <<EOF
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        ServerName gamestats2.gs.$domain
        ServerAlias "gamestats2.gs.$domain, gamestats2.gs.$domain"
 
        ProxyPreserveHost On
 
        ProxyPass / http://127.0.0.1:9002/
        ProxyPassReverse / http://127.0.0.1:9002/
</VirtualHost>
EOF

    cat >/etc/apache2/sites-available/gamestats.gs.$domain.conf <<EOF
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        ServerName gamestats.gs.$domain
        ServerAlias "gamestats.gs.$domain, gamestats.gs.$domain"
        ProxyPreserveHost On
        ProxyPass / http://127.0.0.1:9002/
        ProxyPassReverse / http://127.0.0.1:9002/
</VirtualHost>
EOF

    cat >/etc/apache2/sites-available/nas-naswii-dls1-conntest.$domain.conf <<EOF
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        ServerName naswii.$domain
        ServerAlias "naswii.$domain, naswii.$domain"
        ServerAlias "nas.$domain"
        ServerAlias "nas.$domain, nas.$domain"
        ServerAlias "dls1.$domain"
        ServerAlias "dls1.$domain, dls1.$domain"
        ServerAlias "conntest.$domain"
        ServerAlias "conntest.$domain, conntest.$domain"
        ProxyPreserveHost On
        ProxyPass / http://127.0.0.1:9000/
        ProxyPassReverse / http://127.0.0.1:9000/
</VirtualHost>
EOF

    cat >/etc/apache2/sites-available/sake.gs.$domain.conf <<EOF
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        ServerName sake.gs.$domain
        ServerAlias sake.gs.$domain *.sake.gs.$domain
        ServerAlias secure.sake.gs.$domain
        ServerAlias secure.sake.gs.$domain *.secure.sake.gs.$domain
 
        ProxyPass / http://127.0.0.1:8000/
 
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

    echo "Done!"
    echo "Enabling..."
    apache_mods
    a2ensite *.$domain.conf
    apachectl graceful
}

function create_apache_vh_wiimmfi() {
    # This function will create virtual hosts for Wiimmfi's domains in Apache
    echo -e "\e[1;33mCreating Wiimmfi virtual hosts...\e[1;0m"
    touch /etc/apache2/sites-available/gamestats2.gs.wiimmfi.de.conf
    touch /etc/apache2/sites-available/gamestats.gs.wiimmfi.de.conf
    touch /etc/apache2/sites-available/nas-naswii-dls1-conntest.wiimmfi.de.conf
    touch /etc/apache2/sites-available/sake.gs.wiimmfi.de.conf
    cat >/etc/apache2/sites-available/gamestats2.gs.wiimmfi.de.conf <<EOF
<VirtualHost *:80>
ServerAdmin webmaster@localhost
ServerName gamestats2.gs.wiimmfi.de
ServerAlias "gamestats2.gs.wiimmfi.de, gamestats2.gs.wiimmfi.de"
ProxyPreserveHost On
ProxyPass / http://127.0.0.1:9002/
ProxyPassReverse / http://127.0.0.1:9002/
</VirtualHost>
EOF

    cat >/etc/apache2/sites-available/gamestats.gs.wiimmfi.de.conf <<EOF
<VirtualHost *:80>
ServerAdmin webmaster@localhost
ServerName gamestats.gs.wiimmfi.de
ServerAlias "gamestats.gs.wiimmfi.de, gamestats.gs.wiimmfi.de"
ProxyPreserveHost On
ProxyPass / http://127.0.0.1:9002/
ProxyPassReverse / http://127.0.0.1:9002/
</VirtualHost>
EOF

    cat >/etc/apache2/sites-available/nas-naswii-dls1-conntest.wiimmfi.de.conf <<EOF
<VirtualHost *:80>
ServerAdmin webmaster@localhost
ServerName naswii.wiimmfi.de
ServerAlias "naswii.wiimmfi.de, naswii.wiimmfi.de"
ServerAlias "nas.wiimmfi.de"
ServerAlias "nas.wiimmfi.de, nas.wiimmfi.de"
ServerAlias "dls1.wiimmfi.de"
ServerAlias "dls1.wiimmfi.de, dls1.wiimmfi.de"
ServerAlias "conntest.wiimmfi.de"
ServerAlias "conntest.wiimmfi.de, conntest.wiimmfi.de"
ProxyPreserveHost On
ProxyPass / http://127.0.0.1:9000/
ProxyPassReverse / http://127.0.0.1:9000/
</VirtualHost>
EOF

    cat >/etc/apache2/sites-available/sake.gs.wiimmfi.de.conf <<EOF
<VirtualHost *:80>
ServerAdmin webmaster@localhost
ServerName sake.gs.wiimmfi.de
ServerAlias sake.gs.wiimmfi.de *.sake.gs.wiimmfi.de
ServerAlias secure.sake.gs.wiimmfi.de
ServerAlias secure.sake.gs.wiimmfi.de *.secure.sake.gs.wiimmfi.de
ProxyPass / http://127.0.0.1:8000/
CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

    echo "Done!"
    echo "Enabling...."
    a2ensite *.wiimmfi.de.conf
    service apache2 restart
}

function apache_mods() {
    a2enmod proxy proxy_http
    service apache2 restart
    if ! a2enmod "php7.4"; then
        a2dismod mpm_event
        a2enmod "php7.4"
        service apache2 restart
    fi
    service apache2 restart
}

function dns_config() {
    # This function will configure dnsmasq
    printf "\033c"
    echo -e "\e[1;33m----------Lets configure DNSMASQ now----------\e[1;0m"
    sleep 3s
    # Decided to take this step out, as doing so will create what's known as an open resolver.
    # Having an open resolver is a security risk and is not a good idea.
    # This means that DNS will be restricted to ONLY looking up Nintendo domains.
    #echo "Adding Google DNS (8.8.8.8) to config"
    # We add Google's DNS server to our server so that anyone with our DNS server can still resolve hostnames to IP
    # addresses outside our DNS server. Useful for Dolphin testing
    #cat >>/etc/dnsmasq.conf <<EOF
    #server=8.8.8.8
    #EOF
    #sleep 2s
    echo "What is your EXTERNAL IP?"
    echo "NOTE: If you plan on using this on a LAN, put the IP of your Linux system instead"
    echo "It's also best practice to make this address static in your /etc/network/interfaces file"
    echo "Your LAN IP is"
    hostname -I | cut -f1 -d' '
    echo "Your external IP is:"
    curl -4 -s icanhazip.com
    echo "Please type in either your LAN or external IP"
    read -re IP
    cat >>/etc/dnsmasq.conf <<EOF # Adds your IP you provide to the end of the DNSMASQ config file
address=/nintendowifi.net/$IP
address=/wiimmfi.de/$IP
EOF
    clear
    ifconfig
    read -rp "Please type your primary interfaces's name (e.g - eth0): " interface
    cat >>/etc/dnsmasq.conf <<EOF
interface="$interface"
EOF
    clear
    echo "DNSMasq setup completed!"
    clear
    service dnsmasq restart
    clear
}

function install_required_packages() {
    printf "\033c"
    echo -e "\e[1;33mInstalling required packages...\e[1;0m"

    # Install Minimal Requirements
    apt install -y curl git net-tools dnsmasq apache2 software-properties-common

    # Install Python
    apt install -y python3-software-properties python2.7 python-twisted

    # Add php7.4 repo
    apt -y install lsb-release apt-transport-https ca-certificates
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
    # Refresh
    apt update
    # Install php7.4
    apt -y install php7.4

    # Install MySQL (MariaDB)
    apt update
    apt -y install mariadb-server
    apt -y install php7.4-mysql
    apt -y install sqlite php7.4-sqlite3
    # apt -y install mysql-server
}

function config_mysql() {
    printf "\033c"
    echo -e "\e[1;33mWe will now configure MySQL...\e[1;0m"
    # Config MySQL Password
    debconf-set-selections <<<'mysql-server mysql-server/root_password password passwordhere'
    debconf-set-selections <<<'mysql-server mysql-server/root_password_again password passwordhere'

    # Now we will set up our first admin user
    sleep 2s
    printf "\033c"
    echo -e "\e[1;33mNow we're going to set up our first Admin Portal user.\e[1;0m"
    read -rp "Please enter the username you wish to use: " firstuser
    read -rp "Please enter a password: " password
    hash=$(/var/www/CoWFC/SQL/bcrypt-hash "$password")
    echo "We will now set the rank for $firstuser"
    echo "At the moment, this does nothing. However in later releases, we plan to restrict who can do what."
    echo "1: First Rank"
    echo "2: Second Rank"
    echo "3: Third Rank"
    read -rp "Please enter a rank number [1-3]: " firstuserrank
    echo -e "\e[1;33mFinnaly, we need a password for the mysql user 'cowfc'.\e[1;0m"
    read -rp "Please enter a password for cowfc user (MySQL): " password_db
    echo "That's all, I'll need for now."
    echo -e "\e[1;33mWe will now continue to configure MYSQL server...\e[1;0m"
    echo "Setting up the cowfc users database"
    echo "Create database cowfc" | mysql -u root
    echo "Now importing dumped cowfc database..."
    mysql -u root cowfc </var/www/CoWFC/SQL/cowfc.sql
    echo "Now inserting user $firstuser into the database with password $password, hashed as $hash."
    echo "INSERT INTO users (Username, Password, Rank) VALUES ('$firstuser','$hash','$firstuserrank');" | mysql -u root cowfc
    echo "CREATE USER 'cowfc'@'localhost' IDENTIFIED BY '$password_db';" | mysql -u root
    echo "GRANT ALL PRIVILEGES ON *.* TO 'cowfc'@'localhost';" | mysql -u root
    echo "FLUSH PRIVILEGES;" | mysql -u root
    sed -i -e "s/db_user = root/db_user = cowfc/g" /var/www/html/config.ini
    sed -i -e "s/db_pass = passwordhere/db_pass = $password_db/g" /var/www/html/config.ini
    sleep 1s
}

function re() {
    # Google ReCaptcha Disabled
    sed -i -e "s/recaptcha_enabled = 1/recaptcha_enabled = 0/g" /var/www/html/config.ini
}

function set-server-name() {
    printf "\033c"
    echo -e "\e[1;33mCoWFC allows you to set your server's name\e[1;0m"
    echo "This is useful if you want to whitelabel your server, and not advertise it as CoWFC"
    read -rp "Please enter the server name, or press ENTER to accept the default [CoWFC]: " servernameconfig
    if [ -z "$servernameconfig" ]; then
        echo "Using CoWFC as the server name."
    else
        echo "Setting server name to $servernameconfig"
        sed -i -e "s/name = 'CoWFC'/name = '$servernameconfig'/g" /var/www/html/config.ini
    fi
}

function add-cron() {
    echo "Checking if there is a cron available for $USER"
    if ! crontab -l -u "$USER" | grep "@reboot sh /start-altwfc.sh >/cron-logs/cronlog 2>&1"; then
        echo "No cron job is currently installed"
        echo "Working the magic. Hang tight!"
        cat >/start-altwfc.sh <<EOF
#!/bin/sh
cd /
chmod 777 /var/www/dwc_network_server_emulator -R
cd var/www/dwc_network_server_emulator
python master_server.py
cd /
EOF
        chmod 777 /start-altwfc.sh
        mkdir -p /cron-logs
        if ! command -v crontab; then
            apt install cron -y
        fi
        echo "Creating the cron job now!"
        echo "@reboot sh /start-altwfc.sh >/cron-logs/cronlog 2>&1" >/tmp/alt-cron
        crontab -u "$USER" /tmp/alt-cron
        echo "Done!"
    fi
}

function install_website() {
    rm -rf /var/www/html/*
    mkdir /var/www/html
    cp /var/www/CoWFC/Web/* /var/www/html -R
    chmod 777 /var/www/html/bans.log
    # Let's restart Apache now
    service apache2 restart
    echo "Creating gpcm.db file"
    touch /var/www/dwc_network_server_emulator/gpcm.db
    chmod 777 /var/www/dwc_network_server_emulator/ -R
}

function update() {
    # Original code by Dennis Simpson
    # Modified by Kyle Warwick-Mathieu
    wget -nv -O "$UPDATE_FILE" "$UPDATE_BASE" >&/dev/null
    if cmp "$0" "$UPDATE_FILE" && [ -s "$UPDATE_FILE" ]; then
        echo "Script is not up to date, please wait..."
        sleep 1s
        mv "$UPDATE_FILE" "$0"
        chmod +x "$0"
        echo "[UPDATED] $0"
        sleep 1s
        "$0"
        exit 10
    else
        rm "$UPDATE_FILE"
        echo "Script is up to date !"
    fi
}

# If there is no -s argument then run the updater
# This will call our update function
if [ "$1" != "-s" ]; then
    UPDATE_FILE="$0.tmp"
    UPDATE_BASE="https://raw.githubusercontent.com/EnergyCube/cowfc_installer/master/cowfc-debian.sh"
    update
else
    echo "Update check skipped..."
fi

# Check if the script can be run
if [ -f /etc/os-release ]; then
    if grep -q "Debian" /etc/os-release; then
        CANRUN="TRUE"
    else
        CANRUN="FALSE"
    fi
elif [ -f /etc/lsb-release ]; then
    if grep -q "Ubuntu" /etc/lsb-release; then
        echo "You are running Ubuntu, you can download the Ubuntu CoWFC install script on Github."
        echo "Please check : https://github.com/EnergyCube/cowfc_installer"
    fi
    CANRUN="FALSE"
else
    CANRUN="FALSE"
fi

# Determine if our script can run
if [ "$CANRUN" == "TRUE" ]; then
    if [ "$PWD" == "/var/www" ]; then
        apt update
        # Let's install required packages first.
        install_required_packages
        # Then we will check to see if the Gits for CoWFC and dwc_network_server_emulator exist
        if [ ! -d "/var/www/CoWFC" ]; then
            echo "Git for CoWFC does not exist in /var/www/"
            while ! git clone https://github.com/EnergyCube/CoWFC.git && [ "$C1" -le "4" ]; do
                echo "GIT CLONE FAILED! Retrying....."
                ((C1 = C1 + 1))
            done
            if [ "$C1" == "5" ]; then
                echo "Giving up"
                exit 1
            fi
        fi
        if [ ! -d "/var/www/dwc_network_server_emulator" ]; then
            echo "Git for dwc_network_server_emulator does not exist in /var/www"
            while ! git clone https://github.com/EnergyCube/dwc_network_server_emulator.git && [ "$C2" -le "4" ]; do
                echo "GIT CLONE FAILED! Retrying......"
                ((C2 = C2 + 1))
            done
            if [ "$C2" == "5" ]; then
                echo "Giving up"
                exit 1
            fi
            echo "Setting proper file permissions"
            chmod 777 /var/www/dwc_network_server_emulator/ -R
        fi
        # Configure DNSMASQ
        dns_config
        # Let's set up Apache now
        create_apache_vh_nintendo
        #create_apache_vh_wiimmfi
        #apache_mods    #Already called in create_apache_vh_nintendo # Enable reverse proxy mod and PHP 7.4
        install_website # Install the web contents for CoWFC
        config_mysql    # We will set up the mysql password and create our first user
        re              # Set up reCaptcha (Disabled)
        add-cron        # Makes it so master server can start automatically on boot
        set-server-name # Set your server's name
        cat >>/etc/apache2/apache2.conf <<EOF
HttpProtocolOptions Unsafe LenientMethods Allow0.9
EOF
        echo "Moving the configuration file for more security..."
        mv /var/www/html/config.ini /var/www/config.ini
        echo "Done!"
        # Let's make our hidden file so that our script will know that we've already installed the server
        # This will prevent accidental re-runs
        echo "Finishing..."
        touch /etc/.dwc_installed
        echo "Thank you for installing CoWFC."
        echo "If you wish to access the admin GUI, please go to http://$IP/?page=admin&section=Dashboard"
        read -rp "Please hit the ENTER key to reboot now, or press ctrl+c and reboot whenever it is convenient for you: [ENTER] " rebootenterkey
        if [ -z "$rebootenterkey" ]; then
            reboot
        fi
        reboot
        exit 0
    # DO NOT PUT COMMANDS UNDER THIS FI
    fi
