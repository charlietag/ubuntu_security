echo "-----Displaying current certificates-----"
$certbot_command certificates

echo "-----Be sure to disable apache server...-----"
set -x
systemctl disable apache2.service
systemctl stop apache2.service
# systemctl mask apache2.service
systemctl list-unit-files | grep apache | awk '{print $1}' | xargs | xargs -I{} bash -c "systemctl stop {}; systemctl disable {}; systemctl mask {}"
set +x

#echo "-----restart nginx server to load SSL Cert files...-----"
#systemctl stop nginx ; sleep 3 ; systemctl start nginx
#
#echo "----- Finished restarting nginx server-----"
