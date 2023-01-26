# ***************************
# enhanced top
# ***************************
apt install -y glances htop nmon

# ***************************
# enhaned iostat
# ***************************
# pcp vs dstat cannot exist at the same time
# dstat is easier to use
apt install -y iotop dstat

