# ***************************
# enhanced top
# ***************************
apt install -y glances htop nmon
systemctl stop glances.service
systemctl disable glances.service

# ***************************
# enhaned iostat
# ***************************
# pcp vs dstat cannot exist at the same time
# dstat is easier to use
apt install -y iotop dstat

