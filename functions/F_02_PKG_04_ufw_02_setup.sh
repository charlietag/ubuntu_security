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
# check if firewall-ufw is installed
#--------------------------------------
if [[ -z "$(dpkg -l ufw 2>/dev/null | grep -E "^ii")" ]]; then
  echo "WARNING: Firewall - ufw is not installed!..."
  echo "Please install package \"ufw\""
  exit 1
fi

#--------------------------------------
# Start to setup firewall rules
#--------------------------------------
echo "========================================="
echo "      UFW Default block all incoming traffic (/etc/default/ufw), allow outgoint traffic"
echo "========================================="
# DEFAULT_INPUT_POLICY="DROP"
# DEFAULT_OUTPUT_POLICY="ACCEPT"

# --- /etc/default/ufw ---
# cat /etc/default/ufw | grep -v '^#' | sed '/^$/d'
# IPV6=no
# DEFAULT_FORWARD_POLICY="DROP"
# DEFAULT_APPLICATION_POLICY="SKIP"
# MANAGE_BUILTINS=no
# IPT_SYSCTL=/etc/ufw/sysctl.conf
# IPT_MODULES=""

sed -re '/IPV6/ s/yes/no/g' -i /etc/default/ufw

# ----- Make sure to allow ssh traffic before enabling ufw, avoiding disrupting existing ssh connections ---
# Setup allowed incoming traffic
echo "========================================="
echo "      Resetting all rules to installed defaults"
echo "========================================="
ufw --force disable
ufw --force reset
ufw status verbose

echo "========================================="
echo "      Allowing incoming "
echo "========================================="
for ufw_allow_known_service in ${ufw_allow_known_services[@]}
do
  echo "Allowing traffic \"${ufw_allow_known_service}\"......."
  # Default save config to /etc/ufw/user.rules
  ufw allow ${ufw_allow_known_service}
done

for ufw_allow_customized_port in ${ufw_allow_customized_ports[@]}
do
  echo "Allowing traffic \"${ufw_allow_customized_port}\"......."
  # Default save config to /etc/ufw/user.rules
  ufw allow ${ufw_allow_customized_port}
done

ufw --force disable
ufw --force enable

# Enable ufw.service
systemctl enable ufw.service

echo "--------------Firewall(ufw) Rules-------------"
# verbose - display rules including **default setting (DROP input, ACCEPT output)**
ufw status verbose

# -------------------------------------------
# Ref. https://linuxopsys.com/topics/set-up-firewall-with-ufw-on-ubuntu
# -------------------------------------------
# ufw default allow|deny|reject DIRECTION
#   allow|deny|reject is the permission that you will set
#   DIRECTION is one of the values: incoming, outgoing, or routed
# by default it deny all incoming traffics and allows all outgoing traffics.

# In case someone changed the defaults, you need to change back to ufw default: (run commands In ORDER !)
#   ufw default deny incoming
#   ufw default allow outgoing
# -------------------------------------------
echo "-------------- Check default rules -------------"
local ufw_status_default="$(ufw status verbose | grep 'Default: deny (incoming), allow (outgoing), disabled (routed)')"
ufw status verbose | grep 'Default: deny (incoming), allow (outgoing), disabled (routed)'

if [[ -z "${ufw_status_default}" ]]; then
  # ufw --force reset will do NOTHING about default config
  echo "Default policies has been changed, change back to ufw default"
  ufw default deny incoming
  ufw default allow outgoing
  # These two default commands changed files: /etc/default/ufw, /etc/ufw/user.rules

  # --- check again ---
  ufw status verbose | grep 'Default: deny (incoming), allow (outgoing), disabled (routed)'

  echo "--------------Firewall(ufw) Rules again-------------"
  # verbose - display rules including **default setting (DROP input, ACCEPT output)**
  ufw status verbose
  # --- check again ---
fi


# --------------
# ufw - allow vs limit
# --------------
# ufw allow ssh -> allow ssh port 22/tcp
# ufw limit ssh -> alow ssh port 22/tcp + connection established > 6 times (in 30 seconds) block
#   ---> this block is not permanent, after restart ufw , all gone, and not useful in NAT world(multi user login to the same server), so use fail2ban instead this feature

# --------------
# ufw status numbered (sample)
# --------------
# This is easier to delete rules
# ufw status numbered

#    # > ufw status
#    Status: active
#
#    To                         Action      From
#    --                         ------      ----
#    2222                       LIMIT       Anywhere
#    80/tcp                     ALLOW       Anywhere
#
#    # > ufw delete allow http
#    Rule deleted
#
#
#    # --------------
#    # > ufw status numbered
#    Status: active
#
#         To                         Action      From
#         --                         ------      ----
#    [ 1] 2222                       LIMIT IN    Anywhere
#    [ 2] 80/tcp                     ALLOW IN    Anywhere
#
#    # > ufw delete 2
#    Deleting:
#     allow 80/tcp
#    Proceed with operation (y|n)? y
#    Rule deleted
# --------------


#--------------------------------------
# NOTES (systemd vs ufw)
#--------------------------------------
# * ufw
#   * systemctl
#     * start - trigger ufw initial procedure
#       * ufw.conf (enable onboot)
#         * start ufw service
#       * ufw.conf (disable onboot)
#         * do nothing
#     * stop
#       * trigger ufw instance stop, `NOT change` ufw.conf
#     * systemctl enable ufw
#       * trigger ufw initial procedure onboot
#     * systemctl disable ufw
#       * **DO NOT** trigger ufw initial procedure onboot
#   * ufw enable
#     * start ufw instance and `change` ufw.conf (enable onboot)
#   * ufw disable
#     * stop ufw instance and `change` ufw.conf (disable onboot)
# * ufw config default save path (not like firewalld using xml)
#   * /etc/ufw/user.rules
