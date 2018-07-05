This setup is based on assumption that the platform is using centos7 without any special 
hardening or features install (Plain Vanilla) and httpd and mariadb are not yet install 
which the wp_setup.sh will perform installing. The script will also download latest 
wordpress tar file from wordpress.org and attempt to setup it using 127.0.0.1

Assumptions:
- Need Centos7
- Need Centos7 connect to internert
- Need to be accessible to wordpress.org
- setup IP used is using 127.0.0.1
- files will be copied to /root
- scripts will be run as root
- email will be the way to send for notifications

STEPS:
Copy the 2 files wp_setup.sh and wp_monitor.sh to centos7
run ./wp_setup.sh as root

Once completed, setup cronjob for wp_monitor.sh as shown
* * * * * ./root/wp_monitor.sh 2&>1 > /dev/null
