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
    bash <(curl https://raw.githubusercontent.com/1715173329/v2ray-easy-to-use/master/mkcp-wechatvideo-dynport/install-release.sh)
    rm "/etc/v2ray/config.json" -rf 
    wget -qO /etc/v2ray/config.json "https://raw.githubusercontent.com/1715173329/v2ray-easy-to-use/master/mkcp-wechatvideo-dynport/config.json" 
    UUID=$(cat /proc/sys/kernel/random/uuid)
    hostname=$(hostname)
    Address=$(curl https://ipinfo.io/ip)
    sed -i "s/3922f464-d02d-4124-82bf-ad350c19aacf/${UUID}/g" "/etc/v2ray/config.json"
    service v2ray restart
    clear
    echo -e "\n这是您的连接信息：\n别名(Remarks)：${hostname}\n地址(Address)：${Address}\n端口(Port):8080\n用户ID(ID):${UUID}\n额外ID(AlterID):100\n加密方式(Security)：aes-128-gcm\n传输协议(Network）：kcp\n伪装类型(Type)：wechat-video"
}
    install_v2ray
