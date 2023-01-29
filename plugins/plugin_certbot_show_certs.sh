echo "-----Displaying current certificates-----"
$certbot_command certificates

echo "-----Be sure to disable apache server...-----"
set -x
systemctl disable apache2.service
systemctl stop apache2.service
set +x

#echo "-----restart nginx server to load SSL Cert files...-----"
#systemctl stop nginx ; sleep 3 ; systemctl start nginx
#
#echo "----- Finished restarting nginx server-----"
