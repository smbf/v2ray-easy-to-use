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


function checkenv(){
    if [[ $OS = "centos" ]]; then
	    yum upgrade -y
        yum update -y
        yum install wget curl ntpdate -y
    else
	    apt-get -y upgrade
        apt-get -y update
        apt-get -y install wget curl ntpdate
    fi
}


function install_v2ray(){
    rootness
    checkos
    checkenv
    ntpdate time.nist.gov
    bash <(curl https://http-dynport.v2ray-install.ml/install-release.sh)
    rm -rf "/etc/v2ray/config.json"
    wget -qO /etc/v2ray/config.json "https://http-dynport.v2ray-install.ml/config.json"
	Address=$(curl https://ipinfo.io/ip)
    UUID=$(cat /proc/sys/kernel/random/uuid)
    sed -i "s/3922f464-d02d-4124-82bf-ad350c19aacf/${UUID}/g" "/etc/v2ray/config.json"
    service v2ray restart
	clear
    echo -e "您的连接信息如下："
	echo -e "别名(Remarks)：${hostname}"
	echo -e "地址(Address)：${Address}"
	echo -e "端口(Port)：80"
	echo -e "用户ID(ID)：${UUID}"
	echo -e "额外ID(AlterID)：100"
	echo -e "加密方式(Security)：aes-128-gcm"
	echo -e "传输协议(Network）：tcp"
	echo -e "伪装类型：http"
	echo -e "伪装域名：m.cache.iqiyi.com"
}
    install_v2ray
