# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

# Convert array to multiple lines
# ### ng_limit_req_logpaths ###
#local ng_limit_req_logpath="$(echo -e "$(echo "${ng_limit_req_logpaths[@]}" | sed -e 's/\s\+/\n  /g' )" )"

# ### ng_botsearch_logpaths ###
#local ng_botsearch_logpath="$(echo -e "$(echo "${ng_botsearch_logpaths[@]}" | sed -e 's/\s\+/\n  /g' )" )"

# ------------------------------------
# define script location
# ------------------------------------
local cron_check_script="/root/bin/f2b"


# ------------------------------------
# Check if this script is enabled
# ------------------------------------
# Make sure this script can be run multiple times
sed -i /"${cron_check_script//\//\\/}"/d /etc/crontab

# Make sure apply action is currect.
[[ -z "$(echo "${cron_check_script_status}" | grep "enable")" ]] && eval "${SKIP_SCRIPT}"

#--------------------------------------
# Installing script
#--------------------------------------
# *********************************
# Install f2b.sh script
# *********************************
#local cron_check_script="/root/bin/f2b"

local cron_check_script_dir="$(dirname $cron_check_script)"
test -d $cron_check_script_dir || mkdir -p $cron_check_script_dir

echo "fail2ban-client status|tail -n 1 | cut -d':' -f2 | sed \"s/\\s//g\" | tr ',' '\\n' |xargs -I{} bash -c \"echo \\\"----{}----\\\" ;fail2ban-client status {} ; echo \"" > $cron_check_script
chmod 755 $cron_check_script

# *********************************
# Adding f2b.sh into crontab
# *********************************
echo "1 0 * * * root ${cron_check_script}" >> /etc/crontab

#--------------------------------------
# Rendering fail2ban config
#--------------------------------------
ls /etc/fail2ban/jail.d/* 2>/dev/null | xargs rm -f

echo "========================================="
echo "  Rendering fail2ban configuration"
echo "========================================="
task_copy_using_render

#--------------------------------------
# Start firewall(ufw) & fail2ban
#--------------------------------------
echo "---stopping fail2ban---"
systemctl stop fail2ban

sleep 2

echo "---stopping firewall(ufw)---"
ufw --force disable

sleep 2


echo "---starting firewall(ufw)---"
ufw --force enable

sleep 2

echo "---starting fail2ban---"
local nginx_service_active="$(systemctl is-active nginx)"
echo "Nginx: ${nginx_service_active}"

echo "To avoid failing to start fail2ban:"
echo "restart nginx to make sure nginx log exists..."
systemctl restart nginx
sleep 1

echo "Nginx : ${nginx_service_active}"
if [[ "${nginx_service_active}" != "active" ]]; then
  systemctl stop nginx
  echo "Nginx restarted and stopped..."
else
  echo "Nginx restarted and started..."
fi


systemctl start fail2ban

echo "---enable firewall(ufw), should be enabled by previous step, enable it again---"
systemctl enable ufw.service

echo "---enable fail2ban---"
systemctl enable fail2ban.service

sleep 2


#echo "---reload fail2ban---"
#fail2ban-client reload

#--------------------------------------
# Make sure firewall(ufw) works with fail2ban well
#--------------------------------------
echo "--------------Firewall(ufw) Rules-------------"
ufw status verbose

echo "--------------Fail2ban Status-------------"
fail2ban-client status

echo "--------------Fail2ban Detail Status-------------"
fail2ban-client status|tail -n 1 | cut -d':' -f2 | sed "s/\s//g" | tr ',' '\n' |xargs -I{} bash -c "echo \"----{}----\" ;fail2ban-client status {} ; echo "

