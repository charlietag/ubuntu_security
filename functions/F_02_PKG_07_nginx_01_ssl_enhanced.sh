# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable
# ------------------------------------
# Check if this script is enabled
# ------------------------------------
# Make sure apply action is currect.
[[ -z "$(echo "${this_script_status}" | grep "enable")" ]] && eval "${SKIP_SCRIPT}"

#--------------------------------------
# Start to setup script
#--------------------------------------
task_copy_using_cat

echo "-------------------------------------------------------------"
echo "Generating openssl dhparam."
echo "This might take \"several minutes!\""
echo "Base on your server spec. This might take even \"up to hours\"...!"
echo "-------------------------------------------------------------"
local ssl_dhparam_file="/etc/nginx/server_features/SSL/ssl_dhparam/dhparam2048.pem"
test -f $ssl_dhparam_file || $(which openssl) dhparam -out $ssl_dhparam_file 2048


# 443 ssl default_server
# Ref. https://serverfault.com/questions/578648/properly-setting-up-a-default-nginx-server-for-https
echo "-------------------------------------------------------------"
echo "Generating openssl self signed certificates."
echo "This might take \"several minutes!\""
echo "Base on your server spec. This might take even \"up to hours\"...!"
echo "-------------------------------------------------------------"
test -f /etc/nginx/self_ssl/nginx.key && rm -f /etc/nginx/self_ssl/nginx.key
test -f /etc/nginx/self_ssl/nginx.crt && rm -f /etc/nginx/self_ssl/nginx.crt
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/self_ssl/nginx.key -out /etc/nginx/self_ssl/nginx.crt
