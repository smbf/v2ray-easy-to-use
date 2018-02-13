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
	checkbit
    checkenv
    ntpdate time.nist.gov
    bash <(curl https://shadowsocks-udp2raw-udpspeeder.v2ray-install.ml/install-release.sh)
    rm "/etc/v2ray/config.json" -rf 
    wget -qO /etc/v2ray/config.json "https://shadowsocks-udp2raw-udpspeeder.v2ray-install.ml/config.json" 
	Address=$(curl https://ipinfo.io/ip)
    echo -e "请输入Shadowsocks的连接密码："
    read password
	sed -i "s/sspwd/${password}/g" "/etc/v2ray/config.json"
    service v2ray restart
	mkdir /root/udpspeeder
	cd /root/udpspeeder
	udpspeeder_ver=$(wget -qO- "https://github.com/wangyu-/UDPspeeder/tags"| grep "/wangyu-/UDPspeeder/releases/tag/"| head -n 1| awk -F "/tag/" '{print $2}'| sed 's/\">//') && echo ${udpspeeder_ver}
	wget https://github.com/wangyu-/UDPspeeder/releases/download/${udpspeeder_ver}/speederv2_binaries.tar.gz
	tar -zxf speederv2_binaries.tar.gz
	rm -rf speederv2_binaries.tar.gz
	echo -e "请输入udpspeeder的连接密码："
	read udpspeeder_pwd
	echo -e "您输入的udpspeeder的连接密码为：${udpspeeder_pwd}"
	nohup /root/udpspeeder/speederv2_amd64 -s -l127.0.0.1:10001 -r127.0.0.1:10000 -f2:4 -k "${udpspeeder_pwd}" --mode 0 -q1 > /dev/null 2>&1 &
	mkdir /root/udp2raw
	cd /root/udp2raw
	udp2raw_ver=$(wget -qO- "https://github.com/wangyu-/udp2raw-tunnel/tags"| grep "/wangyu-/udp2raw-tunnel/releases/tag/"| head -n 1| awk -F "/tag/" '{print $2}'| sed 's/\">//') && echo ${udp2raw_ver}
	wget https://github.com/wangyu-/udp2raw-tunnel/releases/download/${udp2raw_ver}/udp2raw_binaries.tar.gz
	tar -zxf udp2raw_binaries.tar.gz
	rm -rf udp2raw_binaries.tar.gz
	echo -e "\n"
	echo -e "请输入udp2raw的连接密码："
	read udp2raw_pwd
	echo -e "您输入的udp2raw的连接密码为：${udp2raw_pwd}"
	nohup /root/udp2raw/udp2raw_amd64 -s -l0.0.0.0:8080 -r127.0.0.1:10001 -a -k "${udp2raw_pwd}" --raw-mode faketcp > /dev/null 2>&1 &
	echo "nohup /root/udpspeeder/speederv2_amd64 -s -l127.0.0.1:10001 -r127.0.0.1:10000 -f2:4 -k "${udpspeeder_pwd}" --mode 0 -q1 > /dev/null 2>&1 &" >> /etc/rc.d/rc.local
	echo "nohup /root/udp2raw/udp2raw_amd64 -s -l0.0.0.0:8080 -r127.0.0.1:10001 -a -k "${udp2raw_pwd}" --raw-mode faketcp > /dev/null 2>&1 &" >> /etc/rc.d/rc.local
	cd /root/
	clear
    echo -e "您的连接信息如下："
	echo -e "udp2raw信息："
	echo -e "服务器地址：${Address}，端口：8080"
	echo -e "密码：${udp2raw_pwd}"
	echo -e "模式：faketcp"
	echo -e "加密模式：aes-128-cbc"
	echo -e "校验模式：md5"
	echo -e "--------------------------------------"
	echo -e "udpspeeder信息："
	echo -e "udpspeeder版本：UDPspeederV2"
	echo -e "服务器地址：udp2raw的本地监听地址，端口：udp2raw的本地监听端口"
	echo -e "密码：${udpspeeder_pwd}"
	echo -e "fec参数：2:4"
	echo -e "其他参数：-q1"
	echo -e "---------------------------------------------------------------------"
	echo -e "Shadowsocks信息："
	echo -e "服务器地址：udpspeeder的本地监听地址"
	echo -e "服务器端口：udpspeeder的本地监听端口"
	echo -e "密码：${password}"
	echo -e "加密方式：aes-256-gcm"
}
    install_v2ray