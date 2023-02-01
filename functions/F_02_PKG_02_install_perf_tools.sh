# ***************************
# enhanced top
# ***************************
# not actually useful
# apt install -y glances htop nmon
#
# systemctl stop glances.service
# systemctl disable glances.service

# --- do not install atop, it runs as an daemon, stop the daemon, not working anymore... ---
# systemctl list-unit-files |grep "^atop" | awk '{print $1}' | xargs | xargs -I{} bash -c "systemctl stop {}; systemctl disable {}"
# systemctl list-unit-files |grep "^atop" | awk '{print $1}' | xargs | xargs -I{} bash -c "systemctl stop {}; systemctl disable {}; systemctl mask {}"
# --- do not install atop, it runs as an daemon, stop the daemon, not working anymore... ---

# ***************************
# enhaned iostat
# ***************************
# pcp vs dstat cannot exist at the same time
# dstat is easier to use
apt install -y iotop dstat

