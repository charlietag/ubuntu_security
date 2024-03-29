#**********************************************
# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

# ------------------------------------
# Make sure apply action is currect.
[[ "${certbot_apply_action}" != "dns-cloudflare" ]] && eval "${SKIP_SCRIPT}"
# ------------------------------------


# Init action
. ${PLUGINS}/plugin_certbot_path.sh
# Before action
. ${PLUGINS}/plugin_certbot_install_check.sh
#**********************************************

pkg_certbot_check="$(dpkg -l python3-certbot-dns-cloudflare 2>/dev/null | grep -E "^ii")"

test -z "${pkg_certbot_check}" && apt install -y certbot python3-certbot-dns-cloudflare
# --------------------------------------------------
# Install certbot using apt official repo - so ignore here
# --------------------------------------------------
# if [[ ! -d "${certbot_eff_org_path}" ]]; then
#   echo "--- Run list current certificates function to make sure ${certbot_eff_org_path} exists (used by dns-cloudflare, pip install certbot-dns-cloudflare) ---"
#   . ${PLUGINS}/plugin_certbot_show_certs.sh
# fi


#**********************************************
# Start to apply letsencrypt SSL cert with DNS txt record verification
# echo "---Install dns-cloudflare if needed  ---"
# IF_CF="$($certbot_python_pip_command list --format=columns | grep certbot-dns-cloudflare)"
# if [[ -z "$IF_CF" ]]; then
#   $certbot_python_pip_command install certbot-dns-cloudflare
# else
#   echo "Pass..."
# fi
# --------------------------------------------------
#                  END
# --------------------------------------------------

echo "--- Generate cloudflare ini file---"
test -d $certbot_cf_path || mkdir -p $certbot_cf_path
echo "${certbot_cf_path} ...done"

# Ref. https://certbot-dns-cloudflare.readthedocs.io/en/stable/
if [[ -n "${certbot_dns_cloudflare_api_token}" ]]; then
  echo "dns_cloudflare_api_token = ${certbot_dns_cloudflare_api_token}" > $certbot_cf_ini
else
  echo "dns_cloudflare_email = ${certbot_dns_cloudflare_email}" > $certbot_cf_ini
  echo "dns_cloudflare_api_key = ${certbot_dns_cloudflare_api_key}" >> $certbot_cf_ini
fi

chmod 400 $certbot_cf_ini
echo "${certbot_cf_ini} ...done"


echo "---Apply cert using certbot via dns-cloudflare plugin ---"
$certbot_command \
  --agree-tos -m $certbot_email --no-eff-email \
  certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials $certbot_cf_ini \
  --dns-cloudflare-propagation-seconds $certbot_wait_cf_seconds \
  -d $certbot_servername \
  -d ${certbot_wild_servername}
  # --server https://acme-v02.api.letsencrypt.org/directory \
#**********************************************

#**********************************************
# After action
. ${PLUGINS}/plugin_certbot_show_certs.sh
#**********************************************
