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
        yum install wget curl -y
    else
        apt-get -y upgrade
        apt-get -y update
        apt-get -y install wget curl
    fi
}


function reinstall_v2ray(){
    checkos
    rootness
    checkenv
    bash <(curl https://raw.githubusercontent.com/1715173329/v2ray-easy-to-use/master/shadowsocks/v2ray-uninstall.sh)
    bash <(curl https://raw.githubusercontent.com/1715173329/v2ray-easy-to-use/master/shadowsocks/v2ray-install.sh)
}
    reinstall_v2ray
