#!/bin/bash
# 脚本文件名:    Init_CentOS8.sh
# 脚本功能:      CentOS8系统初始化
# 脚本版本:      1.0
# 编写日期:      2019/9/28
# 作者：         杜秋
# 作者邮箱:      duqiu521@sina.cn
# 作者微信公众号: 运维及时雨    

#1.关闭防火墙
function close_firewalld(){
    /usr/bin/systemctl stop firewalld.service &> /dev/null
    /usr/bin/systemctl disable firewalld.service &> /dev/null
}
#2.关闭selinux
function close_selinux(){
    /usr/bin/setenforce 0
    /usr/bin/sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
}

#3.配置dnf源(yum)，需要挂载把系统光盘或者iso镜像挂载到光驱,同时设置epel源
function dnf(){
#/usr/bin/mkdir -p /etc/yum.repos.d/bak
#/usr/bin/mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak
/usr/bin/mkdir -p /mnt/cdrom
/usr/bin/mount -o loop /dev/sr0 /mnt/cdrom/AppStream
/usr/bin/dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
/usr/bin/touch /etc/yum.repos.d/local.repo
/usr/bin/cat > /etc/yum.repos.d/local.repo << EOF
[Local]
name=local-repo
baseurl=file:///mnt/cdrom/AppStream
gpgcheck=0
enabled=1
EOF
/usr/bin/dnf makecache
}
#4.配置Chrony并设置时区为亚洲/上海
function chrony(){
/usr/bin/dnf -y install chrony
timedatectl set-timezone Asia/Shanghai
#修改日期时间
#timedatectl set-time "2019-9-28 22:30:55"
#开启或关闭NTP
#timedatectl set-ntp true/flase
#
#修改配置文件
echo '' >/etc/chrony.conf
cat >>/etc/chrony.conf << EOF
server ntp1.aliyun.com iburst
server ntp2.aliyun.com iburst
driftfile /var/lib/chrony/drift
#每11分钟自动矫正系统rtc时钟
rtcsync
#超过2秒立即修正
makestep 2 -1
keyfile /etc/chrony.keys
leapsectz right/UTC
logdir /var/log/chrony
EOF
#同步hwclock
cat >>/etc/sysconfig/chronyd<<EOF
#Command line options for chronyd
SYNC_HWCLOCK=yes
OPTIONS=""
EOF
#使用chronyd服务校验时间
/usr/sbin/hwclock -w
/usr/bin/systemctl start chronyd &> /dev/null
/usr/bin/systemctl enable chronyd &> /dev/null
/usr/bin/chronyc sources
/usr/bin/timedatectl
}
#5.安装日常工具包
function tools(){
	dnf  install -y tcpdump telnet  vim wget  iproute lrzsz tar unzip git gcc
}
#6.DNS设置
function DNS(){
cat >>/etc/resolv.conf<<EOF
#阿里DNS
nameserver 223.5.5.5
#谷歌DNS
nameserver 8.8.8.8
EOF
}
#7.history设置
functon history(){
cat >>/tmp/bash_profile.tmp<<EOF
##By Duqiu
##Linux 中开启多个终端后会产生不同终端的历史命令，若查看对应终端的history，则必须进入相应的终端进行查看，配置一个文件用于存储所有终端执行的命令。
HISTFILE=/root/.commandline_warrior
##历史命令个数
HISTSIZE=10000
##history 格式   
HISTTIMEFORMAT="%F %T `whoami` "
##忽略连续执行的命令
HISTCONTROL=ignoredups
##多个终端同时操作时，采用追加方式记录命令，避免命令被覆盖  
shopt -s histappend
##以下设置的命令不会被记录
HISTIGNORE='pwd:ls:ls -ltr:date:'
EOF
}
cat /tmp/bash_profile.tmp >>/root/.bash_profile
source /root/.bash_profile
#初始化方法
function start_init(){
    close_firewalld;
    close_selinux;
    dnf;
    chrony;
    tools;
    DNS;
    history;
}

start_init
