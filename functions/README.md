## Pre-defined Variables

```bash
# ./start.sh -i F_00_debug
#############################################
         Preparing required lib
#############################################
Updating required lib to lastest version...
Already up to date.

#############################################
            Running start.sh
#############################################

---------------------------------------------------
NTP(systemd-timesyncd) ---> pool.ntp.org
---------------------------------------------------
---------------------------------------------------


==========================================================================================
        F_00_debug
==========================================================================================
-----------lib use only--------
CURRENT_SCRIPT : /root/ubuntu_security/start.sh
CURRENT_FOLDER : /root/ubuntu_security
FUNCTIONS      : /root/ubuntu_security/functions
LIB            : /root/ubuntu_security/../ubuntu_preparation_lib/lib
TEMPLATES      : /root/ubuntu_security/templates
TASKS          : /root/ubuntu_security/../ubuntu_preparation_lib/tasks
HELPERS        : /root/ubuntu_security/helpers
HELPERS_VIEWS  : /root/ubuntu_security/helpers_views

-----------lib use only - predefined vars--------
FIRST_ARGV     : -i
ALL_ARGVS      : F_00_debug

-----------function use only--------
PLUGINS            : /root/ubuntu_security/plugins
TMP                : /root/ubuntu_security/tmp
CONFIG_FOLDER      : /root/ubuntu_security/templates/F_00_debug
DATABAG            : /root/ubuntu_security/databag
DATABAG_FILE       : /root/ubuntu_security/databag/F_00_debug.cfg

-----------function extended use only--------
IF_IS_SOURCED_SCRIPT  : True: use 'return 0' to skip script
IF_IS_FUNCTION        : True: use 'return 0' to skip script
IF_IS_SOURCED_OR_FUNCTION  : True: use 'return 0' to skip script

${BASH_SOURCE[0]}    : /root/ubuntu_security/functions/F_00_debug.sh
${0}                 : ./start.sh
${FUNCNAME}          : source
Skip script sample    : [[ -n "$(eval "${IF_IS_SOURCED_OR_FUNCTION}")" ]] && return 0 || exit 0
Skip script sample short : eval "${SKIP_SCRIPT}"

================= Testing ===============
----------Helper Debug Use-------->>>

-------------------------------------------------------------------
        helper_debug
-------------------------------------------------------------------
HELPER_VIEW_FOLDER : /root/ubuntu_security/helpers_views/helper_debug


----------Task Debug Use-------->>>

-----------------------------------------------
        task_debug
-----------------------------------------------
```
