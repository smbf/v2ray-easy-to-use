#! /bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Make sure only root can run our script
function rootness(){
    if [[ $EUID -ne 0 ]]; then
       echo "Error:This script must be run as root,please run 'sudo su' first." 1>&2
       exit 1
    fi
}
 
 
function checkos(){
    if [ -f /etc/redhat-release ];then
        OS='centos'
    elif [ ! -z "`cat /etc/issue | grep bian`" ];then
        OS='debian'
    elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ];then
        OS='ubuntu'
    else
        echo "Not support OS, Please change OS and retry!"
        exit 1
    fi
}


function uninstall_v2ray(){
    rootness
    checkos
    cd /root/
    service v2ray stop
    update-rc.d -f v2ray remove
    systemctl disable v2ray
    rm -rf /etc/v2ray
    rm -rf /usr/bin/v2ray
    rm -rf /var/log/v2ray
    rm -rf /lib/systemd/system/v2ray.service
    rm -rf /etc/init.d/v2ray
    service caddy stop
    update-rc.d -f caddy remove
    chkconfig --del caddy
    systemctl disable caddy
    rm -rf /usr/local/caddy
    rm -rf /etc/init.d/caddy
    rm -rf /root/.caddy
    rm -rf /usr/local/caddy/Caddyfile
    rm -rf /lib/systemd/system/caddy.service
    rm -rf /v2rayindexpage
    clear
    echo -e "Uninstall is completed, thank you for your use!" 
}
    uninstall_v2ray
