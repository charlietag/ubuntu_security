# ***************************
# enhanced top
# ***************************
apt install -y glances htop nmon atop

systemctl stop glances.service
systemctl disable glances.service

systemctl list-unit-files |grep "^atop" | awk '{print $1}' | xargs | xargs -I{} bash -c "systemctl stop {}; systemctl disable {}"

# ***************************
# enhaned iostat
# ***************************
# pcp vs dstat cannot exist at the same time
# dstat is easier to use
apt install -y iotop dstat

