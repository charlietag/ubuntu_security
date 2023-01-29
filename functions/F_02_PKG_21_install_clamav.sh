# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

# ------------------------------------
# define script location
# ------------------------------------
local cron_check_script="/opt/clamav_script/clamav_clamscan.sh"


# ------------------------------------
# Check if this script is enabled
# ------------------------------------
# Make sure this script can be run multiple times
sed -i /"${cron_check_script//\//\\/}"/d /etc/crontab

# Make sure apply action is currect.
[[ -z "$(echo "${cron_check_script_status}" | grep "enable")" ]] && eval "${SKIP_SCRIPT}"



#--------------------------------------
# Start to setup script
#--------------------------------------
echo "========================================="
echo "   Install clamav"
echo "========================================="
# clamav-cvdupdate - fetch virus database from clamav.net, and self-hosts virus database server use
# clamav-freshclam - update virus database (from clamav.net)

# clamav contains: clamav clamav-base clamav-freshclam libclamav9

pkg_clamav_check="$(dpkg -l clamav 2>/dev/null | grep -E "^ii")"
test -z "${pkg_clamav_check}" && apt install -y clamav
systemctl stop clamav-freshclam.service
systemctl disable clamav-freshclam.service

echo "========================================="
echo "   Setup for $(basename ${cron_check_script})"
echo "========================================="
#task_copy_using_cp
task_copy_using_render_sed

chmod 755 ${cron_check_script}
# *********************************
# Failed logged in check script into crontab
# *********************************
echo "========================================="
echo "   Setup cron for $(basename ${cron_check_script})"
echo "========================================="
echo "Adding script into crontab..."
echo "1 5 * * * root ${cron_check_script}" >> /etc/crontab
