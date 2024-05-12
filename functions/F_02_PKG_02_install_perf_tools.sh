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
# Ubuntu 22.04
# apt install -y iotop dstat

# Ubuntu 24.04
# In Ubuntu 24.04: dstat will be Virtual package of pcp
# So install dstat, will forced to install pcp, which will contains lots of performance tools and processes like pmlogger, pcproxy, etc.
apt install -y iotop
