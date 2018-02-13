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


function install_ssmkcp(){
    rootness
    checkos
    checkenv
    ntpdate time.nist.gov
    bash <(curl https://raw.githubusercontent.com/1715173329/v2ray-easy-to-use/master/shadowsocks/install-release.sh)
    rm -rf "/etc/v2ray/config.json"
    wget -qO /etc/v2ray/config.json "https://raw.githubusercontent.com/1715173329/v2ray-easy-to-use/master/shadowsocks/config.json" 
    echo -e "请输入Shadowsocks的连接密码："
    read password
    sed -i "s/sspwd/${password}/g" "/etc/v2ray/config.json"
    Address=$(curl https://ipinfo.io/ip)
    service v2ray restart
    clear
    echo -e "您的连接信息如下："
    echo -e "服务器地址：${Address}"
    echo -e "服务器端口：8080"
    echo -e "密码：${password}"
    echo -e "加密方式：aes-256-gcm"
}
    install_ssmkcp
