# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

# ------------------------------------
# Make sure apply action is currect.
[[ -z "$(echo "${postfix_installation}" | grep "enable")" ]] && eval "${SKIP_SCRIPT}"
# ------------------------------------


#--------------------------------------
# Start - install postfix
#--------------------------------------
apt install -y postfix

# -----------
# AUTH (cyrus)
# -----------
# --- might need for corp ---
# libsasl2-modules-ldap/jammy-updates 2.1.27+dfsg2-3ubuntu1.1 amd64
#   Cyrus SASL - pluggable authentication modules (LDAP)
# --- might need for corp ---

# libsasl2-2 shoud be installed after postfix installation
apt install -y libsasl2-2 libsasl2-dev
systemctl stop postfix
