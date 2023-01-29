Table of Contents
=================
- [Purpose](#purpose)
- [Environment](#environment)
- [Warning](#warning)
- [Quick Install](#quick-install)
  * [Configuration](#configuration)
  * [Installation](#installation)
- [Run Security Check](#run-security-check)
  * [Basic os check](#basic-os-check)
- [Installed Packages](#installed-packages)
- [Quick Note - Package](#quick-note---package)
  * [Nginx module - ubuntu_preparation](#nginx-module---ubuntu_preparation)
  * [Firewall(ufw) usage](#firewall-ufw--usage)
  * [Fail2ban usage](#fail2ban-usage)
- [Quick Note - Fail2ban flow](#quick-note---fail2ban-flow)
- [Quick Note - Fail2ban all detailed status](#quick-note---fail2ban-all-detailed-status)
- [Install SSL (Letsencrypt) - A+](#install-ssl-letsencrypt---a)
  * [Setup Nginx](#setup-nginx)
  * [Certbot prerequisite](#certbot-prerequisite)
  * [Certbot usage](#certbot-usage)
- [Log analyzer](#log-analyzer)
  * [GoAccess usage](#goaccess-usage)
  * [Logwatch usage](#logwatch-usage)
- [Performance monitor](#performance-monitor)
  * [Iotop usage](#iotop-usage)
  * [Glances usage](#glances-usage)
- [CHANGELOG](#changelog)

# Purpose
**This presumes that you've done with** [ubuntu_preparation](https://github.com/charlietag/ubuntu_preparation)
1. This is used for check if your linux server is being hacked.
1. This could also help you to enhance your servers' security with **firewall (ufw)** and **fail2ban**.
1. This is also designed for **PRODUCTION** single server, which means this is suit for small business.

# Supported Environment
  * Ubuntu 22.04
    * ubuntu_security
      * release : `main` `v1.x.x`


# Warning
* If you found something is weired and not sure if you've been hacked.  You'd better reinstall your server.
* ClamAV (clamscan) - if you're going to scan virus through clamscan (ClamAV), which is installed by default ([ubuntu_security](https://github.com/charlietag/ubuntu_security))
  * `clamscan` is a **memory monster**
  * RAM (Physical + SWAP) Capacity recommendations for clamscan (ClamAV): **>= 4GB**
  * (Tip) mkswap if RAM is insufficient to run clamscan
    * [ubuntu_preparation#SWAP_FILE](https://github.com/charlietag/ubuntu_preparation#warning)
* If your ***physical memory is <= 1GB***, be sure stop some service before getting started
  * (**Nginx) is needed** when **TLS (certbot) certificates is required**

    ```bash
    systemctl list-unit-files |grep -E 'mariadb\.service|php[[:print:]]*fpm\.service|puma[[:print:]]*\.service' | awk '{print $1}' | xargs | xargs -I{} bash -c "echo --- Stop and Disable {} ---; systemctl stop {} ; systemctl disable {}; echo"
    ```

  * **Nginx is not needed**, when **NO TLS certificates** required

    ```bash
    systemctl list-unit-files |grep -E 'mariadb\.service|php[[:print:]]*fpm\.service|puma[[:print:]]*\.service|nginx\.service' | awk '{print $1}' | xargs | xargs -I{} bash -c "echo --- Stop and Disable {} ---; systemctl stop {} ; systemctl disable {}; echo"
    ```

# Quick Install
## Configuration
  * Download and run check

    ```bash
    dnf install -y git
    git clone https://github.com/charlietag/ubuntu_security.git
    ```

  * Make sure config files exists , you can copy from sample to **modify**.

    ```bash
    cd databag
    ls |xargs -i bash -c "cp {} \$(echo {}|sed 's/\.sample//g')"
    ```

  * Mostly used configuration :
    * **DEV** use (server in **Local**)
      * **NO NEED** to setup config, just `./start -a` without config, by default, the following will be executed

        ```bash
        functions/
        ├── F_00_list_os_users
        ├── F_01_CHECK_01_os
        ├── F_01_CHECK_02_failed_login
        ├── F_01_CHECK_03_last_login
        ├── F_01_CHECK_04_ssh_config
        ├── F_02_PKG_02_install_perf_tools
        ├── F_02_PKG_04_firewall (ufw)_01_install
        ├── F_02_PKG_05_fail2ban_01_install
        ```

    * **DEV** use (server in **Cloud**)
      * It would be better to work with **VPS Firewall** for more secure enviroment
        * Firewall(ufw) + Fail2ban + **VPS Firewall (Vultr / DigitalOcean)**

      ```bash
      databag/
      ├── F_02_PKG_01_install_log_analyzer.cfg
      ├── F_02_PKG_04_firewall (ufw)_02_setup.cfg (rementer add customized port for dev, like 8000 for laravel, 3000 for rails)
      ├── F_02_PKG_05_fail2ban_02_setup.cfg
      ├── F_02_PKG_05_fail2ban_03_nginx_check_banned.cfg
      ├── F_02_PKG_07_nginx_01_ssl_enhanced.cfg
      ├── F_02_PKG_08_redmine_01_fail2ban.cfg
      ├── F_03_CHECK_01_check_scripts.cfg
      └── _postfix.cfg
      ```

        * ~~F_02_PKG_21_install_clamav.cfg~~
        * ~~_nginx_modules.cfg~~


    * **Production** use (server in **Local**)

      ```bash
      databag/
      ├── F_02_PKG_01_install_log_analyzer.cfg
      └── _postfix.cfg
      ```

        * ~~F_02_PKG_21_install_clamav.cfg~~

    * **Production** use (server in **Cloud**)

      ```bash
      databag/
      ├── _certbot.cfg
      ├── F_02_PKG_01_install_log_analyzer.cfg
      ├── F_02_PKG_04_firewall (ufw)_02_setup.cfg
      ├── F_02_PKG_05_fail2ban_02_setup.cfg
      ├── F_02_PKG_05_fail2ban_03_nginx_check_banned.cfg
      ├── F_02_PKG_07_nginx_01_ssl_enhanced.cfg
      ├── F_02_PKG_07_nginx_02_ssl_site_config.cfg
      ├── F_02_PKG_08_redmine_01_fail2ban.cfg
      ├── F_03_CHECK_01_check_scripts.cfg
      └── _postfix.cfg
      ```

        * ~~F_02_PKG_21_install_clamav.cfg~~
        * ~~_nginx_modules.cfg~~

  * Verify config files (with syntax color).

    ```bash
    cd databag

    echo ; \
    ls *.cfg | xargs -i bash -c " \
    echo -e '\e[0;33m'; \
    echo ---------------------------; \
    echo {}; \
    echo ---------------------------; \
    echo -n -e '\033[00m' ; \
    echo -n -e '\e[0;32m'; \
    cat {} | grep -vE '^\s*#' |sed '/^\s*$/d'; \
    echo -e '\033[00m' ; \
    echo "
    ```

  * Verify **ONLY modified** config files (with syntax color).

    ```bash
    cd databag

    echo ; \
    ls *.cfg | xargs -i bash -c " \
    echo -e '\e[0;33m'; \
    echo ---------------------------; \
    echo {}; \
    echo ---------------------------; \
    echo -n -e '\033[00m' ; \
    echo -n -e '\e[0;32m'; \
    cat {} | grep -v 'plugin_load_databag.sh' | grep -vE '^\s*#' |sed '/^\s*$/d'; \
    echo -e '\033[00m' ; \
    echo "
    ```

## Installation
* First time finish [ubuntu_preparation](https://github.com/charlietag/ubuntu_preparation), be sure to do a **REBOOT**, before installing [ubuntu_security](https://github.com/charlietag/ubuntu_security)

* Run **ALL** to do the following with one command
  * ./start -a
  * Run security check
  * Install security package "**firewall (ufw)**" , "**fail2ban**" , "**letsencrypt**" , "**nginx waf**" , "**nginx header**"
* ~~To avoid running **ALL**, to **APPLY** and **DESTROY** **letsencrypt** cert **at the same time**.~~
  * ~~DO NOT run ***./start.sh -a***~~

# Run Security Check

## Basic os check
* Command

  ```bash
  ./start.sh -i \
    F_00_debug \
    F_00_list_os_users \
    F_01_CHECK_01_os \
    F_01_CHECK_02_failed_login \
    F_01_CHECK_03_last_login \
    F_01_CHECK_04_ssh_config \
    F_01_CHECK_05_hosts_config \
    ...
  ```

* Check OS
  * Verify os basic command (ls,cp, etc..) using command "rpm -Vf"
* Check failed loging
  * Check failed attempt ssh login
* Check ssh config
  * Check if root permit
  * Check if ssh port set to default 22
* List os users
  * Check current how many common user created
* Check last login
  * Check latest successfully login
* Check hosts file (/etc/hosts)

  ```bash
  127.0.0.1 original content
  ::1       original content
  127.0.0.1 $(hostname)
  ::1       $(hostname)
  ```

# Installed Packages
* Firewall(ufw)
  * Allowed port
    * http
    * https
    * 2222
* Fail2ban
  * Default filtered
    * sshd (mode=aggressive)
    * nginx-limit-req
    * nginx-botsearch

# Quick Note - Package
## Nginx module - ubuntu_preparation
  * limit_req_zone
    * This is installed by default on my *ubuntu_preparation repo*
      * **[Link](https://github.com/charlietag/ubuntu_preparation/blob/master/templates/F_06_01_setup_nginx_include/opt/nginx/conf/include.d/limit_req_zone.conf)**
    * This would prevent your server from **DDOS** attacks.

## NGINX 3rd Party Modules - ubuntu_security
  https://www.nginx.com/resources/wiki/modules/

  * Headers More

    ```bash
    more_set_headers    "Server: CharlieTag"; # Default=> Nginx: "nginx" , Apache: "Apache"
    ```

  * ModSecurity

    ```bash
    ...
    modsecurity on;
    ...
    ```

  * ModSecurity - supported policies
    * OWASP CRS
      * https://github.com/SpiderLabs/owasp-modsecurity-crs
      * Memory consumption
        * 100 MB / per nginx process
      * Should reference Azure config, to Avoid False Positive
        * https://docs.microsoft.com/en-us/azure/application-gateway/waf-overview

          ```bash
          curl -s https://docs.microsoft.com/zh-tw/azure/application-gateway/waf-overview |grep -Eo "REQUEST-[[:digit:]]+" |sort -n | uniq | sed ':a;N;$!ba;s/\n/|/g'
          ```

        * if you really need OWASP
        * if you have time to maintain WAF rules (OWASP-CRS) yourself
      * Reference: REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example , RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example
        * REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example
          * Usage

            ```bash
            # ModSecurity Rule Exclusion: Disable all SQLi and XSS rules
            SecRule REQUEST_FILENAME "@beginsWith /admin" \
                "id:1004,\
                phase:2,\
                pass,\
                nolog,\
                ctl:ruleRemoveById=941000-942999"
            # This would cause error
            # ...no SecRule specified...
            # ctl:ruleRemoveById=941000-942999"
            ```

        * RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example
          * Usage

            ```bash
            SecRuleRemoveById 949100 949110 959100
            ```


    * COMODO
      * https://waf.comodo.com
      * Memory consumption
        * 300 MB / per nginx process
      * Recommended: COMODO
        (register an account for 1-year-free, require renew 1-year-free order every year)
       * OWSASP would have false positive while:
         * Wordpress , updating articles
         * Redmine   , Click between pages
    * Website Vulnerability Scanner
      * nikto
        * Install

          ```bash
          dnf install -y nikto
          ```

        * Start to scan
          ```bash
          nikto -h myrails.centos8.localdomain
          ```

      * skipfish
        * Install

          ```bash
          dnf install -y skipfish
          ```

        * Start to scan (output_result_folder must be an empty folder)
          ```bash
          skipfish -o output_result_folder http://myrails.centos8.localdomain
          ```

## Firewall(ufw) usage
*- Default block all traffic, except rules you define below*
* Allow/revoke specific service

  ```basn
  firewall-cmd --add-service=http --permanent
  firewall-cmd --remore-service=http --permanent
  ```

* Allow/revoke specific port

  ```bash
  firewall-cmd --add-port=2222/tcp --permanent
  firewall-cmd --remove-port=2222/tcp --permanent
  ```

* List all current rules setting

  ```bash
  firewall-cmd --list-all
  ```

* After setup done with argument "**--permanent**", all rules save into the following file by default

  ```bash
  /etc/firewall (ufw)/zone/public.xml
  ```

* So reload firewall (ufw) to activate setting.
  ```bash
  firewall-cmd --reload
  ```

* Services(http,https) defines in

  ```bash
  /usr/lib/firewall (ufw)/services/*
  ```

* After running this installation, your firewall (ufw) will only allow http , https , ***customized ssh port***

## Fail2ban usage
*- Setting: port, in fail2ban configuration is based on firewall (ufw) services name.*

*- Determine if rules of fail2ban is inserted into nft via firewall (ufw) command*

  * Confirm fail2ban works with **nft** well

    ```bash
    nft list ruleset | grep {banned_ip}
    ```

  * List fail2ban status

    ```bash
    fail2ban-client status
    ```

  * List detailed status for specific **JAIL NAME**, including banned IP

    ```bash
    fail2ban-client status nginx-botsearch
    ```

  * Unban banned ip for specific **JAIL NAME**

    ```bash
    fail2ban-client set nginx-botsearch unbanip 192.168.1.72
    ```

  * Unban banned specific ip for all **JAIL NAME**

    ```bash
    fail2ban-client unban 192.168.1.72 ... 192.168.1.72
    ```

  * List banned ip timeout for specific **JAIL NAME**

    ```bash
    ipset list fail2ban-nginx-botsearch
    ```

  * Fail2ban keeps showing WARN

    ```bash
    2019-12-11 16:23:53,108 fail2ban.ipdns          [4812]: WARNING Unable to find a corresponding IP address for xxx.xxx.xxx.xxx.server.com: [Errno -5] No address associated with hostname
    ```

    * ~~Solution~~
      * ~~fail2ban-client unban --all~~
      * ~~fail2ban-client restart~~
    * Root cause (Not verified)
      * fail2ban will dns lookup / dns reserve lookup hostname, this will trigger this error message
      * fail2ban will not dns lookup / dns reserve lookup 127.0.0.1
      * And why VM test server will not show this err message
        * The hostname of VM test server is not in `/etc/hosts` but also not in dns. So all the results when dns resolves. are `NXDOMAIN`, the same result... PASS
    * Solution 1
      * make sure `hostname` is in `/etc/hosts` (**both ipv4 and ipv6 is needed**)

        ```bash
        # cat /etc/hosts
        127.0.0.1 web.example.com
        ::1       web.example.com
        ```

    * Solution 2
      * make sure DNS record is correct
        * A record
          * `web.example.com    A   xxx.xxx.xxx.xxx`
        * PTR record (reverse record)
          * `xxx.xxx.xxx.xxx    PTR   web.example.com`

# Quick Note - Fail2ban flow
* **(Procedure) Be sure to start *"Firewall(ufw) / Fail2ban"* in the following order**

  ```bash
  systemctl stop fail2ban
  systemctl stop firewall (ufw)
  systemctl start firewall (ufw)
  systemctl start fail2ban
  ```

- The following flow are executed automatically by **Fail2ban**
  * Create [ipset-nmae] *(What actually done behind)*

      ```bash
      ipset create <ipmset> hash:ip timeout <bantime>
      ```

  * Reject all traffic with [ipset-name] *(What actually done behind)*

      ```bash
      firewall-cmd --direct --add-rule <family> filter <chain> 0 -p <protocol> -m multiport --dports <port> -m set --match-set <ipmset> src -j <blocktype>
      ```

  * Parse log
  * **Found** illigal IP
  * **Ban** IP using **ipset** with timeout argument *(What actually done behind)*

      ```bash
      ipset add <ipmset> <ip> timeout <bantime> -exist
      ```

# Quick Note - Fail2ban all detailed status
* *List all jail detailed status in faster way*

  **Command**

    ```bash
    # fail2ban-client status|tail -n 1 | cut -d':' -f2 | sed "s/\s//g" | tr ',' '\n' |xargs -i bash -c "echo \"----{}----\" ;fail2ban-client status {} ; echo "
    ```

  **Result**

    ```bash
    ----nginx-botsearch----
    Status for the jail: nginx-botsearch
    |- Filter
    |  |- Currently failed: 0
    |  |- Total failed:     0
    |  `- File list:        /var/log/nginx/error.log /var/log/nginx/default.error.log /var/log/nginx/redmine.centos8.localdomain.error.log /var/log/nginx/myrails.centos8.localdomain.error.log /var/log/nginx/mylaravel.centos8.localdomain.error.log
    `- Actions
       |- Currently banned: 1
       |- Total banned:     1
       `- Banned IP list:   10.255.255.254

    ----nginx-limit-req----
    Status for the jail: nginx-limit-req
    |- Filter
    |  |- Currently failed: 0
    |  |- Total failed:     0
    |  `- File list:        /var/log/nginx/error.log /var/log/nginx/default.error.log /var/log/nginx/redmine.centos8.localdomain.error.log /var/log/nginx/myrails.centos8.localdomain.error.log /var/log/nginx/mylaravel.centos8.localdomain.error.log
    `- Actions
       |- Currently banned: 1
       |- Total banned:     1
       `- Banned IP list:   10.255.255.254

    ----nginx-modsecurity----
    Status for the jail: nginx-modsecurity
    |- Filter
    |  |- Currently failed: 0
    |  |- Total failed:     1
    |  `- File list:        /var/log/nginx/error.log /var/log/nginx/default.error.log /var/log/nginx/redmine.centos8.localdomain.error.log /var/log/nginx/myrails.centos8.localdomain.error.log /var/log/nginx/mylaravel.centos8.localdomain.error.log
    `- Actions
       |- Currently banned: 1
       |- Total banned:     1
       `- Banned IP list:   10.255.255.254

    ----nginx-redmine----
    Status for the jail: nginx-redmine
    |- Filter
    |  |- Currently failed: 0
    |  |- Total failed:     0
    |  `- File list:        /home/rubyuser/rails_sites/redmine/log/production.log
    `- Actions
       |- Currently banned: 1
       |- Total banned:     1
       `- Banned IP list:   10.255.255.254

    ----sshd----
    Status for the jail: sshd
    |- Filter
    |  |- Currently failed: 0
    |  |- Total failed:     0
    |  `- Journal matches:  _SYSTEMD_UNIT=sshd.service + _COMM=sshd
    `- Actions
       |- Currently banned: 1
       |- Total banned:     1
       `- Banned IP list:   10.255.255.254
    ```

# Install SSL (Letsencrypt) - A+
## Setup Nginx

  **This will automatically setup after installation**

  **Also you will get a score "A+" in [SSLTEST](https://www.ssllabs.com/ssltest)**

  **Default : TLS 1.2 1.3 enabled**

## Certbot prerequisite
  **You will need 2 privileges**
  1. Web server control , to install ssl certificates.
  1. DNS control , to do ACME verification using TXT record.

## Certbot usage
  * Sign certificate (**RECOMMEND**), verified by DNS txt record

    ```bash
    certbot-auto --agree-tos -m $certbot_email --no-eff-email certonly --manual --preferred-challenges dns -d {domain}
    ```

  * Sign certificate , verified by web server root

    ```bash
    certbot-auto --agree-tos -m $certbot_email --no-eff-email certonly --webroot -w /{PATH}/laravel/public -d {domain} -n
    ```

  * Display all certificates

    ```bash
    certbot-auto certificates
    ```

  * Renew all certificates

    ```bash
    certbot-auto renew
    ```

  * Revoke and delete certificate

    ```bash
    certbot-auto revoke --cert-path /etc/letsencrypt/live/{domain}/cert.pem
    certbot-auto delete --cert-name {domain}
    ```

  * New site - url : gen nginx site config + apply letsencrypt ssl only

    ```bash
    ./start.sh -i F_02_PKG_06_nginx_02_ssl_site_config
    ```

    **Before going on, be sure http port is reachable, otherwise webroot will fail (limitation for webroot verification!)**

    ```bash
    ./start.sh -i F_02_PKG_07_certbot_02_apply_webroot
    ```

  * New site - url (wildcard) : gen nginx site config + apply letsencrypt ssl only

    ```bash
    ./start.sh -i F_02_PKG_06_nginx_02_ssl_site_config
    ./start.sh -i F_02_PKG_07_certbot_02_apply_dns-cloudflare
    ```

# Log analyzer
## GoAccess usage
  *- Generate nginx http log report in html.*

  **Reference the official description** [GoAccess](https://goaccess.io/)

  ```bash
  cat xxx.access.log | goaccess > xxx.html
  ```

## Logwatch usage
  *- View log analysis report.*

  ```bash
  logwatch
  ```

## pflogsumm usage (not installed by default, use logwatch instead)
  *- View log analysis of postfix.*

  ```bash
  /usr/sbin/pflogsumm -d yesterday /var/log/maillog
  ```

# Performance monitor
## Glances usage (not installed by default, not provide by CentOS 8 - base,epel,appstream)
  *- Just like command "top", but more than that.*

  ```bash
  glances
  ```

## Iotop usage
  *- Just like command "top", but just for IO.*

  ```bash
  iotop
  ```

# CHANGELOG
* 2022/12/04
  * tag: v0.0.0
      * Initial Ubuntu Security
* 2023/01/30
  * tag: v1.0.0
    * changelog: https://github.com/charlietag/ubuntu_security/compare/v0.0.0...v1.0.0
      * First release of ubuntu_security
