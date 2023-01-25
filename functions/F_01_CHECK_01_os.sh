# =====================
# Enable databag
# =====================
# DATABAG_CFG:enable

# Ref. https://serverfault.com/questions/322518/can-dpkg-verify-files-from-an-installed-package
# Simulate rpm -Vf /bin/ls
dpkg-verify() {
    exitcode=0
    for file in $*; do
        pkg=`dpkg -S "$file" | cut -d: -f 1`
        hashfile="/var/lib/dpkg/info/$pkg.md5sums"
        if [ -s "$hashfile" ]; then
            rfile=`echo "$file" | cut -d/ -f 2-`
            phash=`grep -E "$rfile\$" "$hashfile" | cut -d\  -f 1`
            hash=`md5sum "$file" | cut -d\  -f 1`
            if [ "$hash" = "$phash" ]; then
                echo "$file: ok"
            else
                echo "$file: CHANGED"
                exitcode=1
            fi
        else
            echo "$file: UNKNOWN"
            exitcode=1
        fi
    done
    return $exitcode
}


for os_command in ${os_commands[@]}
do
  echo "===${os_command}==="
  check_result="$(dpkg-verify $os_command | grep ': ok')"
  if [ -n "${check_result}" ]
  then
    echo "PASS"
  else
    echo "Command \"${os_command}\" is hacked"
    echo "${check_result}"
  fi
  echo ""
done
