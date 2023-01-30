apt install -y fail2ban
systemctl stop fail2ban
systemctl disable fail2ban.service

ls /etc/fail2ban/jail.d/* 2>/dev/null | xargs rm -f
