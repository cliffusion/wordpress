#########################################
# Name: wp_monitor.sh
# Written by: Cliff Ching
# Written date: 4 July 2018
# Updated By:
# Updated Date:
# Description: To monitor wordpress setup and its LAMP components
# Run this in centos 7 using root
#########################################


WEB_MON=0
HTTP_MON=0
DB_MON=0
MAIL_JOB=0
WP_ADMIN_EMAIL="admin@admin.com"

### Validate if root is used ###
if [ `whoami` != "root" ] ; then
echo "Please run ${0} as root"
exit 0
fi

### Monitor Web Page Availbility ###
### Continue to use 127.0.0.1 as the IP for web as sample ###
curl -Isk http://127.0.0.1/wordpress/ | egrep "200 OK"
if [ $? -eq 1 ]; then
    WEB_MON=1
else
    WEB_MON=0
fi
sleep 1

### Monitor process startup for httpd ###
if [ `ps -ef | grep http | grep -v grep | wc -l` -lt 1 ]; then
    HTTP_MON=1
else
    HTTP_MON=0
fi
sleep 1

### Monitor process startup for mariadb ###
if [ `ps -ef | grep maria | grep -v grep | wc -l` -lt 1 ]; then
DB_MON=1
else
DB_MON=0
fi
sleep 1

### Check status and collate all erros and send out in email ###
touch /var/log/mon.status
echo "Subject: Wordpress Service Down" > /tmp/email.txt
echo "" >> /tmp/email.txt
if [ $WEB_MON -eq 1 ]; then
    echo "Wordpress Webpage is unavailble" >> /tmp/email.txt
    MAIL_JOB=1
fi
if [ $HTTP_MON -eq 1 ]; then
    echo "HTTPD is unavailble" >> /tmp/email.txt
    MAIL_JOB=1
fi
if [ $DB_MON -eq 1 ]; then
    echo "MariaDB is unavailble" >> /tmp/email.txt
    MAIL_JOB=1
fi
if [ $MAIL_JOB -eq 1 ]; then
    sendmail ${WP_ADMIN_EMAIL} < /tmp/email.txt
fi


### Other Features to test for improvements:
### - Check connectivity to mariadb using the credential login
### - Check non-SSL is not available if SSL is turn on for apache
### - Atempt to perform first level self-heal by restarting the affected service
### and log a record for this while still send email out for alert


