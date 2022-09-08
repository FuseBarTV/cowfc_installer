CoWFC Installer
======

This script installs the CoWFC front-end and back-end from https://github.com/EnergyCube/CoWFC

✅ Support Ubuntu 14.04 & 16.04 (& 16.04 AWS)

✅ Support Debian 10 (❌ LAN Reported not working ! Only tested on a VPS using a domain name)

🔨 Contributing
-------

Please open pull requests.

🔧 Error reporting
-------

Create a new issue and communicate all informations that you can.

📝 How to use
-------

![image](https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Ubuntu_logo.svg/100px-Ubuntu_logo.svg.png)

`mkdir /var/www ; cd /var/www && wget https://raw.githubusercontent.com/EnergyCube/cowfc_installer/master/cowfc.sh && chmod +x cowfc.sh && ./cowfc.sh`

After system reboot : `cd /var/www && ./cowfc.sh`

Remplace cowfc.sh with cowfc_for_aws_ubuntu_16.sh if you are using AWS.

![image](https://www.debian.org/logos/openlogo-nd-25.png) Debian
----

`wget https://raw.githubusercontent.com/FuseBarTV/cowfc_installer/master/cowfc-debian.sh && chmod +x cowfc-debian.sh && ./cowfc-debian.sh`

📖 Notes
-------

This script comes in 3 phases for Ubuntu. Each phase involves a reboot
-	Add the PHP 7.1 repo
-	Continue CoWFC install
-	Reboot after CoWFC install

This script comes in 1 phases for Debian.
-	Install CoWFC & Reboot

Ubuntu script use PHP 7.1 & MySQL\
Debian script use PHP 7.4 & MariaDB\
AWS Ubuntu 16.04 script use PHP 7.0 & MySQL

I am currently in the works of converting scripts to work with todays software

❤️ Credits
-------
kyle95wm