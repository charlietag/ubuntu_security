#**********************************************
# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

# ------------------------------------
# Make sure apply action is currect.
[[ -z "$(echo "${certbot_apply_action}" | grep -E "dns-cloudflare|dns|webroot|renew|revoke_destroy")" ]] && eval "${SKIP_SCRIPT}"
# ------------------------------------


# --------------------------------------------------
# Install certbot using apt official repo - so ignore here
# --------------------------------------------------
# Init action
# . ${PLUGINS}/plugin_certbot_path.sh
# --------------------------------------------------
#                  END
# --------------------------------------------------


#**********************************************
pkg_certbot_check="$(dpkg -l certbot 2>/dev/null | grep -E "^ii")"

test -z "${pkg_certbot_check}" && apt install -y certbot python3-certbot-dns-cloudflare

systemctl list-unit-files |grep -Ei "^certbot" | awk '{print $1}' | xargs | xargs -I{} bash -c "systemctl stop {}; systemctl disable {}"

# --------------------------------------------------
# Install certbot using apt official repo - so ignore here
# --------------------------------------------------
# ******* Download certbot *******
# if [ -d $certbot_path ]
# then
#   rm -fr $certbot_path
#   rm -fr $certbot_eff_org_path
# fi
#
# echo "---Downloading CERTBOT---"
# cd $certbot_root
# git clone $certbot_src_url

# --------------------------------------------------------------------------------------------------------------------------------------------------------------
# To avoid interactive prompt interrupts the installation
#   --quiet , not just silence mode , but also force "apt install -y packages"
#   not just command with--quiet forces "apt install -y packages", while "certbot renew" will also force "apt install -y packages"

# Before action
# . ${PLUGINS}/plugin_certbot_install_check.sh
# $certbot_command certificates --quiet
# --------------------------------------------------
#                  END
# --------------------------------------------------

# --------------------------------------------------
# Install certbot using apt official repo - so ignore here
# --------------------------------------------------
# Make sure eff folder exists
# echo "--- Run list current certificates function to make sure ${certbot_eff_org_path} exists (used by dns-cloudflare, pip install certbot-dns-cloudflare) ---"
# . ${PLUGINS}/plugin_certbot_show_certs.sh
# --------------------------------------------------
#                  END
# --------------------------------------------------
# --------------------------------------------------------------------------------------------------------------------------------------------------------------

# --------------------------------------------------
# Install certbot using apt official repo - so ignore here
# --------------------------------------------------
# echo "Be sure to disable apache server..."
# systemctl disable apache2.service
# systemctl stop apache2.service

# ******* Check certbot, determine if git clone success*******
# echo "---Determining git status of CERTBOT---"
# echo "change dir to \"${certbot_path}\""
# cd $certbot_path
# local git_ret_certbot="$(git pull | grep 'Already up to date')"
# if [ -z "${git_ret_certbot}" ]
# then
#   echo "Git clone of certbot is FAILED !..."
#   echo "Please try to reinstall certbot!..."
#   git status
#   exit 1
# fi
# echo "${git_ret_certbot}"
# --------------------------------------------------
#                  END
# --------------------------------------------------

# ******* Install certbot renew script *******
echo "========================================="
echo "   Install certbot renew script"
echo "========================================="
task_copy_using_cat

local certbot_renew_script="/opt/certbot_scripts/certbot-auto_renew"
chmod 755 $certbot_renew_script

# *********************************
# Adding certificates renewal into crontab
# *********************************
echo "Adding cert renewal into crontab..."
sed -i /certbot-auto_renew/d /etc/crontab
echo "1 3 * * * root ${certbot_renew_script}" >> /etc/crontab

