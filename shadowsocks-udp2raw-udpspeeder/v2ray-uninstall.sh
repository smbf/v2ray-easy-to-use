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


function checkbit(){
    if [ $(uname -m)=x86_64 ];then
        echo "Check finished."
    else
        echo "Not support bit, Please change x86_64 and retry!"
        exit 1
    fi
}


function uninstall_v2ray(){
    rootness
    checkos
	checkbit
    service v2ray stop
    update-rc.d -f v2ray remove
    systemctl disable v2ray
    rm -rf /etc/v2ray
    rm -rf /usr/bin/v2ray
    rm -rf /var/log/v2ray
    rm -rf /lib/systemd/system/v2ray.service
    rm -rf /etc/init.d/v2ray
	kill -9 $(ps -ef|grep "udp2raw_amd64"|grep -v grep|awk '{print $2}')
	kill -9 $(ps -ef|grep "speederv2_amd64"|grep -v grep|awk '{print $2}')
	rm -rf /root/udp2raw
	rm -rf /root/udpspeeder
	rm -rf /etc/rc.d/rc.local
	clear
    echo -e "Uninstall is completed, thank you for your use!" 
}
    uninstall_v2ray
