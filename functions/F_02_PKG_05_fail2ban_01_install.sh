local if_fail2ban_installed="$(dpkg -l fail2ban 2>/dev/null | grep -E "^ii")"
if [[ -n "${if_fail2ban_installed}" ]]; then
  apt purge -y fail2ban
fi


local fail2ban_apt_version="$(apt info fail2ban 2>/dev/null| grep -i version | grep -Eo '[[:digit:]]+\.[[:digit:]]')"

if [[ "${fail2ban_apt_version}" = "1.0" ]]; then
  cd ${TMP} && mkdir fail2ban-source
  cd ${TMP}/fail2ban-source && wget http://kr.archive.ubuntu.com/ubuntu/pool/universe/f/fail2ban/fail2ban_1.1.0-2_all.deb
  dpkg -i fail2ban_1.1.0-2_all.deb

  cd ${TMP} && SAFE_DELETE "fail2ban-source"
else
  apt install -y fail2ban
fi

local if_fail2ban_installed="$(dpkg -l fail2ban 2>/dev/null | grep -E "^ii")"
if [[ -z "${if_fail2ban_installed}" ]]; then
  echo "-------- Failed installing package 'fail2ban' --------"
  exit 1
fi

systemctl stop fail2ban
systemctl disable fail2ban.service

ls /etc/fail2ban/jail.d/* 2>/dev/null | xargs rm -f
