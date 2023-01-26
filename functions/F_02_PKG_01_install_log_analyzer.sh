# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable
# ------------------------------------
# Check if this script is enabled
# ------------------------------------
# Make sure apply action is currect.
[[ -z "$(echo "${this_script_status}" | grep "enable")" ]] && eval "${SKIP_SCRIPT}"


# ***************************
# logwatch
# ***************************
apt install -y logwatch

# ***************************
# goaccess
# ***************************
#-----------------------------------------------------------------------------------------
# Install dependency packages (for Manually install)
#-----------------------------------------------------------------------------------------
# Move to F_01_ENV_03_basic_01_pkgs_install.sh (ubuntu_preparation)
local check_geoip="$(dpkg -l geoip-bin 2>/dev/null | grep -E "^ii")"
test -z "${check_geoip}" && apt install -y geoip-bin geoip-database geoipupdate libgeoip-dev

#-----------------------------------------------------------------------------------------
# Compile to install goaccess
#-----------------------------------------------------------------------------------------
if [[ -n "${compile_enable}" ]] && [[ "${compile_enable}" = "yes" ]] ; then
  # ---- compile ---
  cd $TMP

  local goaccess_script="/usr/local/bin/goaccess"
  local goaccess_url="https://github.com/allinurl/goaccess/archive/v${compile_goaccess_ver}.tar.gz"

  # Download source code
  wget $goaccess_url -O - | tar -xz

  # Compile bin file
  cd goaccess-${compile_goaccess_ver}
  autoreconf -fiv
  ./configure --enable-utf8 --enable-geoip=legacy
  make
  cp goaccess ${goaccess_script}

  # Delete source code
  cd $TMP
  SAFE_DELETE "goaccess-${compile_goaccess_ver}"
  # ---- compile end ---

else
  #-----------------------------------------------------------------------------------------
  # Install goaccess through apt-get
  #-----------------------------------------------------------------------------------------
  apt install -y goaccess

fi


# ***************************
# Postfix log parse
# ref. http://www.postfix.org/addon.html#logfile
# ***************************
# The same function as what logwatch does
#apt install -y pflogsumm
#sed -i /pflogsumm/d /etc/crontab
#echo "01 01 * * * root /usr/sbin/pflogsumm -d yesterday /var/log/maillog" >> /etc/crontab

# ***************************
# setup config
# ***************************
task_copy_using_cat
