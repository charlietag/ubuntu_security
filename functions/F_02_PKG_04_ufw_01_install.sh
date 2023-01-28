apt install -y ufw
ufw --force disable
systemctl stop ufw.service
systemctl disable ufw.service
