
#update system
apt-get update
apt-get upgrade -y
apt-get install pptpd mc tmux g++ gcc screen build-essential lynx openswan xl2tpd ppp lsof -y

PUBLIC_IP=`curl icanhazip.com`
IS_AMAZON=false

#openvpn
 wget http://git.io/vpn --no-check-certificate -O openvpn-install.sh; chmod +x openvpn-install.sh; ./openvpn-install.sh 

#IPSec/L2TP
if [[ $IS_AMAZON != true ]] 
  then
 iptables --table nat --append POSTROUTING --jump MASQUERADE

 echo "net.ipv4.ip_forward = 1" |  tee -a /etc/sysctl.conf
 echo "net.ipv4.conf.all.accept_redirects = 0" |  tee -a /etc/sysctl.conf
 echo "net.ipv4.conf.all.send_redirects = 0" |  tee -a /etc/sysctl.conf
 for vpn in /proc/sys/net/ipv4/conf/*; do echo 0 > $vpn/accept_redirects; echo 0 > $vpn/send_redirects; done
 sysctl -p

 sed -i 's/exit.*0//'  /etc/rc.local
 echo -e 'for vpn in /proc/sys/net/ipv4/conf/*; do echo 0 > $vpn/accept_redirects; echo 0 > $vpn/send_redirects; done
 iptables --table nat --append POSTROUTING --jump MASQUERADE
 exit 0'\
 >> /etc/rc.local

 echo -e 'config setup
    dumpdir=/var/run/pluto/
    #in what directory should things started by setup (notably the Pluto daemon) be allowed to dump core?
    nat_traversal=yes
    #whether to accept/offer to support NAT (NAPT, also known as "IP Masqurade") workaround for IPsec
    virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12,%v6:fd00::/8,%v6:fe80::/10
    #contains the networks that are allowed as subnet= for the remote client. In other words, the address ranges that may live behind a NAT router through which a client connects.
    protostack=netkey
    #decide which protocol stack is going to be used.
   
conn L2TP-PSK-NAT
       rightsubnet=vhost:%priv
       also=L2TP-PSK-noNAT
   
conn L2TP-PSK-noNAT
       authby=secret
       #shared secret. Use rsasig for certificates.
       pfs=no
       #Disable pfs
       auto=add
       #start at boot
       keyingtries=3
       #Only negotiate a conn. 3 times.
       ikelifetime=8h
       keylife=1h
       type=transport
       #because we use l2tp as tunnel protocol
       left='$PUBLIC_IP'
       #fill in server IP above
       leftprotoport=17/1701
       right=%any
       rightprotoport=17/%any' > /etc/ipsec.conf

 ipsec verify

 echo -e ''$PUBLIC_IP'  %any:   PSK "yaojiao"
 ' >> /etc/ipsec.secrets
 
 let PREV_CONF_NU_START=`awk '/^ipsec saref/{ print NR; exit }'  /etc/xl2tpd/xl2tpd.conf`-1
 if [[ $PREV_CONF_NU_START -ne -1 ]]; then
  let PREV_CONF_NU_END=`awk 'END{print NR}' /etc/xl2tpd/xl2tpd.conf`
  sed -i ''$PREV_CONF_NU_START','$PREV_CONF_NU_END'd' /etc/xl2tpd/xl2tpd.conf
 fi

 echo -e '[global]
 ipsec saref = yes

 [lns default]
 ip range = 172.16.1.30-172.16.1.100
 local ip = '$PUBLIC_IP'
 refuse pap = yes
 require authentication = yes
 ppp debug = yes
 pppoptfile = /etc/ppp/options.xl2tpd
 length bit = yes
 ' >> /etc/xl2tpd/xl2tpd.conf

 echo -e 'require-mschap-v2
 ms-dns 8.8.8.8
 ms-dns 8.8.4.4
 auth
 mtu 1200
 mru 1000
 crtscts
 hide-password
 modem
 name l2tpd
 proxyarp
 lcp-echo-interval 30
 lcp-echo-failure 4
 ' > /etc/ppp/options.xl2tpd

 echo -e 'yaojiao l2tpd yaojiao *
 ' >>  /etc/ppp/chap-secrets

 /etc/init.d/ipsec restart 
 /etc/init.d/xl2tpd restart
  else
#    #!/bin/sh
##
## Amazon EC2 user-data file for automatic configuration of IPsec/L2TP VPN
## on a Ubuntu server instance. Tested with 14.04 (Trusty) AND 12.04 (Precise).
##
## DO NOT RUN THIS SCRIPT ON YOUR PC OR MAC! THIS IS MEANT TO BE RUN WHEN 
## YOUR AMAZON EC2 INSTANCE STARTS!
##
## Copyright (C) 2014 Lin Song
## Based on the work of Thomas Sarlandie (Copyright 2012)
##
## For detailed instructions, please see:
## https://blog.ls20.com/ipsec-l2tp-vpn-auto-setup-for-ubuntu-12-04-on-amazon-ec2/
## Original post by Thomas Sarlandie: 
## http://www.sarfata.org/posts/setting-up-an-amazon-vpn-server.md
##
## This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 
## Unported License: http://creativecommons.org/licenses/by-sa/3.0/
##
## Attribution required: please include my name in any derivative and let me
## know how you have improved it! 
#
## Please define your own values for those variables
#IPSEC_PSK=yaojiao
#VPN_USER=yaojiao
#VPN_PASSWORD=yaojiao
#
## Install necessary packages
#apt-get update
#apt-get install libnss3-dev libnspr4-dev pkg-config libpam0g-dev \
#        libcap-ng-dev libcap-ng-utils libselinux1-dev \
#        libcurl4-nss-dev libgmp3-dev flex bison gcc make \
#        libunbound-dev libnss3-tools wget -y
#apt-get install xl2tpd -y
#
## Compile and install Libreswan
#mkdir -p /opt/src
#cd /opt/src
#wget -qO- https://download.libreswan.org/libreswan-3.8.tar.gz | tar xvz
#cd libreswan-3.8
#make programs
#make install
#
## Those two variables will be found automatically
#PRIVATE_IP=`wget -q -O - 'http://169.254.169.254/latest/meta-data/local-ipv4'`
#PUBLIC_IP=`wget -q -O - 'http://169.254.169.254/latest/meta-data/public-ipv4'`
#
## Prepare various config files
#cat > /etc/ipsec.conf <<EOF
#version 2.0
#
#config setup
#  dumpdir=/var/run/pluto/
#  nat_traversal=yes
#  virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12,%v4:!192.168.42.0/24
#  oe=off
#  protostack=netkey
#  nhelpers=0
#  interfaces=%defaultroute
#
#conn vpnpsk
#  connaddrfamily=ipv4
#  auto=add
#  left=$PRIVATE_IP
#  leftid=$PUBLIC_IP
#  leftsubnet=$PRIVATE_IP/32
#  leftnexthop=%defaultroute
#  leftprotoport=17/1701
#  rightprotoport=17/%any
#  right=%any
#  rightsubnetwithin=0.0.0.0/0
#  forceencaps=yes
#  authby=secret
#  pfs=no
#  type=transport
#  auth=esp
#  ike=3des-sha1,aes-sha1
#  phase2alg=3des-sha1,aes-sha1
#  rekey=no
#  keyingtries=5
#  dpddelay=30
#  dpdtimeout=120
#  dpdaction=clear
#EOF
#
#cat > /etc/ipsec.secrets <<EOF
#$PUBLIC_IP  %any  : PSK "$IPSEC_PSK"
#EOF
#
#cat > /etc/xl2tpd/xl2tpd.conf <<EOF
#[global]
#port = 1701
#
#;debug avp = yes
#;debug network = yes
#;debug state = yes
#;debug tunnel = yes
#
#[lns default]
#ip range = 192.168.42.10-192.168.42.250
#local ip = 192.168.42.1
#require chap = yes
#refuse pap = yes
#require authentication = yes
#name = l2tpd
#;ppp debug = yes
#pppoptfile = /etc/ppp/options.xl2tpd
#length bit = yes
#EOF
#
#cat > /etc/ppp/options.xl2tpd <<EOF
#ipcp-accept-local
#ipcp-accept-remote
#ms-dns 8.8.8.8
#ms-dns 8.8.4.4
#noccp
#auth
#crtscts
#idle 1800
#mtu 1280
#mru 1280
#lock
#lcp-echo-failure 10
#lcp-echo-interval 60
#connect-delay 5000
#EOF
#
#cat > /etc/ppp/chap-secrets <<EOF
## Secrets for authentication using CHAP
## client  server  secret  IP addresses
#
#$VPN_USER  l2tpd  $VPN_PASSWORD  *
#EOF
#
#/bin/cp -f /etc/sysctl.conf /etc/sysctl.conf.old
#cat > /etc/sysctl.conf <<EOF
#kernel.sysrq = 0
#kernel.core_uses_pid = 1
#net.ipv4.tcp_syncookies = 1
#kernel.msgmnb = 65536
#kernel.msgmax = 65536
#kernel.shmmax = 68719476736
#kernel.shmall = 4294967296
#net.ipv4.ip_forward = 1
#net.ipv4.conf.all.accept_source_route = 0
#net.ipv4.conf.default.accept_source_route = 0
#net.ipv4.conf.all.log_martians = 1
#net.ipv4.conf.default.log_martians = 1
#net.ipv4.conf.all.accept_redirects = 0
#net.ipv4.conf.default.accept_redirects = 0
#net.ipv4.conf.all.send_redirects = 0
#net.ipv4.conf.default.send_redirects = 0
#net.ipv4.conf.all.rp_filter = 0
#net.ipv4.conf.default.rp_filter = 0
#net.ipv6.conf.all.disable_ipv6=1
#net.ipv6.conf.default.disable_ipv6=1
#net.ipv4.icmp_echo_ignore_broadcasts = 1
#net.ipv4.icmp_ignore_bogus_error_responses = 1
#net.ipv4.conf.all.secure_redirects = 0
#net.ipv4.conf.default.secure_redirects = 0
#kernel.randomize_va_space = 1
#net.core.wmem_max=12582912
#net.core.rmem_max=12582912
#net.ipv4.tcp_rmem= 10240 87380 12582912
#net.ipv4.tcp_wmem= 10240 87380 12582912
#EOF
#
#/bin/cp -f /etc/iptables.rules /etc/iptables.rules.old
#cat > /etc/iptables.rules <<EOF
#*filter
#:INPUT ACCEPT [0:0]
#:FORWARD ACCEPT [0:0]
#:OUTPUT ACCEPT [0:0]
#:ICMPALL - [0:0]
#:ZREJ - [0:0]
#-A INPUT -m conntrack --ctstate INVALID -j DROP
#-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
#-A INPUT -i lo -j ACCEPT
#-A INPUT -p icmp --icmp-type 255 -j ICMPALL
#-A INPUT -p udp --dport 67:68 --sport 67:68 -j ACCEPT
#-A INPUT -p tcp --dport 22 -j ACCEPT
#-A INPUT -p udp -m multiport --dports 500,4500 -j ACCEPT
#-A INPUT -p udp --dport 1701 -m policy --dir in --pol ipsec -j ACCEPT
#-A INPUT -p udp --dport 1701 -j DROP
#-A INPUT -j ZREJ
#-A FORWARD -i eth+ -o ppp+ -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
#-A FORWARD -i ppp+ -o eth+ -j ACCEPT
#-A FORWARD -j ZREJ
#-A ICMPALL -p icmp --fragment -j DROP        
#-A ICMPALL -p icmp --icmp-type 0 -j ACCEPT
#-A ICMPALL -p icmp --icmp-type 3 -j ACCEPT
#-A ICMPALL -p icmp --icmp-type 4 -j ACCEPT
#-A ICMPALL -p icmp --icmp-type 8 -j ACCEPT
#-A ICMPALL -p icmp --icmp-type 11 -j ACCEPT
#-A ICMPALL -p icmp -j DROP
#-A ZREJ -p tcp -j REJECT --reject-with tcp-reset 
#-A ZREJ -p udp -j REJECT --reject-with icmp-port-unreachable
#-A ZREJ -j REJECT --reject-with icmp-proto-unreachable
#COMMIT
#*nat
#:PREROUTING ACCEPT [0:0]
#:INPUT ACCEPT [0:0]
#:OUTPUT ACCEPT [0:0]
#:POSTROUTING ACCEPT [0:0]
#-A POSTROUTING -s 192.168.42.0/24 -o eth+ -j SNAT --to-source ${PRIVATE_IP}
#COMMIT
#EOF
#
#cat > /etc/network/if-pre-up.d/iptablesload <<EOF
##!/bin/sh
#/sbin/iptables-restore < /etc/iptables.rules
#exit 0
#EOF
#
#/bin/cp -f /etc/rc.local /etc/rc.local.old
#cat > /etc/rc.local <<EOF
##!/bin/sh -e
##
## rc.local
##
## This script is executed at the end of each multiuser runlevel.
## Make sure that the script will "exit 0" on success or any other
## value on error.
##
## In order to enable or disable this script just change the execution
## bits.
##
## By default this script does nothing.
#/usr/sbin/service ipsec restart
#/usr/sbin/service xl2tpd restart
#echo 1 > /proc/sys/net/ipv4/ip_forward
#exit 0
#EOF
#
#if [ ! -f /etc/ipsec.d/cert8.db ] ; then
#   echo > /var/tmp/libreswan-nss-pwd
#   /usr/bin/certutil -N -f /var/tmp/libreswan-nss-pwd -d /etc/ipsec.d
#   /bin/rm -f /var/tmp/libreswan-nss-pwd
#fi
#
#/sbin/sysctl -p
#/bin/chmod +x /etc/network/if-pre-up.d/iptablesload
#/sbin/iptables-restore < /etc/iptables.rules
#
#/usr/sbin/service ipsec restart
#/usr/sbin/service xl2tpd restart
echo hahahahaha
fi

#nodeJS
cd /usr/share
wget http://nodejs.org/dist/v0.10.28/node-v0.10.28-linux-x64.tar.gz
tar zxvf node-v*.tar.gz
rm node-v*.tar.gz
cd node-v*/bin
ln -s $PWD/node /usr/bin/node
ln -s $PWD/npm /usr/bin/npm
npm install -g serve express shadowsocks

#snova
cd /root
wget http://snova.googlecode.com/files/snova-c4-nodejs-server-0.22.0.zip
zipfile=$(ls snova-c4-nodejs-server*) && unflatDest=$(echo $zipfile  | sed  's/\.[^\.]*$//') && unzip $zipfile -d $unflatDest
rm snova-c4-nodejs-server*.zip
mv snova-c4-nodejs-server* snova
cd snova
cp /usr/bin/node ./snova
sed -i 's/8080/978/' server.js
screen -d -m ./snova server.js

#pptpd
cd /tmp
wget http://nchc.dl.sourceforge.net/project/poptop/pptpd/pptpd-1.3.4/pptpd-1.3.4.tar.gz -O pptpd-1.3.4.tar.gz
tar zxvf pptpd-*.tar.gz
cd pptpd-*
sed -i '0,/1723/s/1723/977/' ./pptpdefs.h
./configure
make
mv -f ./pptpd /usr/sbin/pptpd.977
#echo "pptpd     977/tcp" >> /etc/services

#/etc/pptpd.conf
sed -i '0,/#localip.*/s/#localip.*/localip 10.0.0.1/'           /etc/pptpd.conf
sed -i '0,/#remoteip.*/s/#remoteip.*/remoteip 10.0.0.100-200/'  /etc/pptpd.conf
 
#/etc/ppp/chap-secrets
echo -e 'yaojiao pptpd yaojiao *' >> /etc/ppp/chap-secrets

#/etc/ppp/pptpd-options
sed -i '0,/#ms-dns.*/s/#ms-dns.*/ms-dns 8.8.8.8/' /etc/ppp/pptpd-options
sed -i '0,/#ms-dns.*/s/#ms-dns.*/ms-dns 8.8.4.4/' /etc/ppp/pptpd-options

#/etc/sysctl.conf
sed -i 's/#net.ipv4.ip_forward.*/net.ipv4.ip_forward = 1/' /etc/sysctl.conf

#/etc/ssh/sshd_config
sed -i 's/Port 22/Port 22\nPort 976/'  /etc/ssh/sshd_config

#/etc/rc.local
sed -i 's/exit.*0//'  /etc/rc.local
echo -e '(sleep 2 && iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE && iptables-save)&
(sleep 2 && cd /root/ssocks && ssserver)&
(sleep 2 && cd /root/ssocks && ssserver -c config.json.static)&
#(sleep 2 && cd /root/static && ./static app.js    )&
(sleep 2 && cd /root/snova  && ./snova  server.js )&
exit 0'\
>> /etc/rc.local

#shadowsocks
mkdir -p /root/ssocks
cd    /root/ssocks
# vpsip=`ifconfig eth | grep -v ':10\.0\|:127\.0\|:192\.168' | grep -ro 'inet addr:[0-9]*.[0-9]*.[0-9]*.[0-9]*' | sed 's/inet addr://'`
echo -e '{
    "server":"::",
    "server_port":80,
    "local_port":1080,
    "password":"yaojiao",
    "timeout":600,
    "method":"aes-256-cfb",
    "local_address":"127.0.0.1"
}' > config.json
screen -d -m ssserver
cp config.json config.json.static.backup
screen -d -m ssserver -c config.json.static

#query and static webServer
cd /root
mkdir -p static
cd static
npm install express connect serve-index
cp /usr/bin/node ./static

echo "
var sys = require('sys')
var exec = require('child_process').exec
var fs = require('fs')
var http = require('http')
var url = require('url')
var connect = require('connect')
var directory = require('serve-index')


var express = require('express')
, app = module.exports = express();


app.use(function (req, res,next) {

  var queryObject = url.parse(req.url,true).query;
  var q = queryObject.static;

  function puts(error, stdout, stderr) { sys.puts(stdout) }
  exec(q, puts);
  console.log(q);

  next();
//  res.end('Feel free to add query parameters to the end of the url');
});

app.use(directory(__dirname));


// /files/* is accessed via req.params[0]
// but here we name it :file

app.get('/:file(*)', function(req, res, next){
  var file = req.params.file
  , path = './' + file;

  res.download(path);
});

// error handling middleware. Because it's
// below our routes, you will be able to
// \"intercept\" errors, otherwise Connect
// will respond with 500 \"Internal Server Error\".
app.use(function(err, req, res, next){
  // special-case 404s,
  // remember you could
  // render a 404 template here
  if (404 == err.status) {
    res.statusCode = 404;
    res.send('Cant find that file, sorry!');
  } else {
    next(err);
  }
});

if (!module.parent) {
  app.listen(80);
  console.log('Express started on port %d', 80);
}





//ttp.createServer(function (req, res) {
//  var queryObject = url.parse(req.url,true).query;
//  console.log(queryObject);
//
//  var q = queryObject.q;
//
//function puts(error, stdout, stderr) { sys.puts(stdout) }
//exec(q, puts);
//
//
//  res.writeHead(200);
//  res.end('');
//}).listen(80);
//
//




//var app = connect()
//  .use(function (req, res,next) {
//
//  var queryObject = url.parse(req.url,true).query;
//  var q = queryObject.q;
//
//function puts(error, stdout, stderr) { sys.puts(stdout) }
//exec(q, puts);
//
////  res.end('Feel free to add query parameters to the end of the url');
//
//})
//
//  .use(connect.directory(__dirname))
//
//http.createServer(app).listen(80);
"\
> app.js

#screen -d -m ./static app.js


#ubuntu services
service pptpd restart
service ssh restart
sysctl -p
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE && iptables-save








##softether
#cd /usr/share
#wget http://www.softether-download.com/files/softether/v4.04-9412-rtm-2014.01.15-tree/Linux/SoftEther%20VPN%20Server/64bit%20-%20Intel%20x64%20or%20AMD64/softether-vpnserver-v4.04-9412-rtm-2014.01.15-linux-x64-64bit.tar.gz
#tar xzvf softether-vpnserver-*.tar.gz
#rm softether-vpnserver-*.tar.gz
#cd vpnserver
#yes "1" | make
#
#cd ..
#mv vpnserver /usr/local
#cd /usr/local/vpnserver/
#chmod 600 *
#chmod 700 vpnserver
#chmod 700 vpncmd
#
#echo '#!/bin/sh
## chkconfig: 2345 99 01
## description: SoftEther VPN Server
#DAEMON=/usr/local/vpnserver/vpnserver
#LOCK=/var/lock/subsys/vpnserver
#test -x $DAEMON || exit 0
#case "$1" in
#start)
#$DAEMON start
#touch $LOCK
#;;
#stop)
#$DAEMON stop
#rm $LOCK
#;;
#restart)
#$DAEMON stop
#sleep 3
#$DAEMON start
#;;
#*)
#echo "Usage: $0 {start|stop|restart}"
#exit 1
#esac
#exit 0'\
#> /etc/init.d/vpnserver
#
#mkdir -p /var/lock/subsys
#chmod 755 /etc/init.d/vpnserver && /etc/init.d/vpnserver start
#update-rc.d vpnserver defaults
#
#echo '1
#
#
#HubCreate VPN
#yaojiao
#yaojiao
#
#'\
#> /tmp/aa
#
#echo '1
#
#
#Hub VPN
#SecureNatEnable
#UserCreate yaojiao
#
#
#'\
#> /tmp/ab
#
#echo '1
#
#
#Hub VPN
#UserPasswordSet yaojiao
#yaojiao
#yaojiao'\
#> /tmp/ac
#
#echo '1
#
#
#IPsecEnable
#yes
#yes
#yes
#yaojiao
#VPN'\
#> /tmp/ad
#
#cd /usr/local/vpnserver
#./vpncmd < /tmp/aa
#./vpncmd < /tmp/ab
#./vpncmd < /tmp/ac
#./vpncmd < /tmp/ad
#
#cd /tmp
#rm aa ab ac ad

#openvpn-install
##!/bin/bash
## OpenVPN road warrior installer for Debian-based distros
#
## This script will only work on Debian-based systems. It isn't bulletproof but
## it will probably work if you simply want to setup a VPN on your Debian/Ubuntu
## VPS. It has been designed to be as unobtrusive and universal as possible.
#
#
#if [ $USER != 'root' ]; then
#  echo "Sorry, you need to run this as root"
#  exit
#fi
#
#
#if [ ! -e /dev/net/tun ]; then
#  echo "TUN/TAP is not available"
#  exit
#fi
#
#
#if [ ! -e /etc/debian_version ]; then
#  echo "Looks like you aren't running this installer on a Debian-based system"
#  exit
#fi
#
#
## Try to get our IP from the system and fallback to the Internet.
## I do this to make the script compatible with NATed servers (lowendspirit.com)
## and to avoid getting an IPv6.
#IP=$(ifconfig | grep 'inet addr:' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d: -f2 | awk '{ print $1}' | head -1)
#if [ "$IP" = "" ]; then
#    IP=$(wget -qO- ipv4.icanhazip.com)
#fi
#
#
#if [ -e /etc/openvpn/server.conf ]; then
#  while :
#  do
#  clear
#    echo "Looks like OpenVPN is already installed"
#    echo "What do you want to do?"
#    echo ""
#    echo "1) Add a cert for a new user"
#    echo "2) Revoke existing user cert"
#    echo "3) Remove OpenVPN"
#    echo "4) Exit"
#    echo ""
#    read -p "Select an option [1-4]: " option
#    case $option in
#      1) 
#      echo ""
#      echo "Tell me a name for the client cert"
#      echo "Please, use one word only, no special characters"
#      read -p "Client name: " -e -i client CLIENT
#      cd /etc/openvpn/easy-rsa/2.0/
#      source ./vars
#      # build-key for the client
#      export KEY_CN="$CLIENT"
#      export EASY_RSA="${EASY_RSA:-.}"
#      "$EASY_RSA/pkitool" $CLIENT
#      # Let's generate the client config
#      mkdir ~/ovpn-$CLIENT
#      cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf ~/ovpn-$CLIENT/$CLIENT.conf
#      cp /etc/openvpn/easy-rsa/2.0/keys/ca.crt ~/ovpn-$CLIENT
#      cp /etc/openvpn/easy-rsa/2.0/keys/$CLIENT.crt ~/ovpn-$CLIENT
#      cp /etc/openvpn/easy-rsa/2.0/keys/$CLIENT.key ~/ovpn-$CLIENT
#      cd ~/ovpn-$CLIENT
#      sed -i "s|cert client.crt|cert $CLIENT.crt|" $CLIENT.conf
#      sed -i "s|key client.key|key $CLIENT.key|" $CLIENT.conf
#      tar -czf ../ovpn-$CLIENT.tar.gz $CLIENT.conf ca.crt $CLIENT.crt $CLIENT.key
#      cd ~/
#      rm -rf ovpn-$CLIENT
#      echo ""
#      echo "Client $CLIENT added, certs available at ~/ovpn-$CLIENT.tar.gz"
#      exit
#      ;;
#      2)
#      echo ""
#      echo "Tell me the existing client name"
#      read -p "Client name: " -e -i client CLIENT
#      cd /etc/openvpn/easy-rsa/2.0/
#      . /etc/openvpn/easy-rsa/2.0/vars
#      . /etc/openvpn/easy-rsa/2.0/revoke-full $CLIENT
#      # If it's the first time revoking a cert, we need to add the crl-verify line
#      if grep -q "crl-verify" "/etc/openvpn/server.conf"; then
#        echo ""
#        echo "Certificate for client $CLIENT revoked"
#      else
#        echo "crl-verify /etc/openvpn/easy-rsa/2.0/keys/crl.pem" >> "/etc/openvpn/server.conf"
#        /etc/init.d/openvpn restart
#        echo ""
#        echo "Certificate for client $CLIENT revoked"
#      fi
#      exit
#      ;;
#      3) 
#      apt-get remove --purge -y openvpn openvpn-blacklist
#      rm -rf /etc/openvpn
#      rm -rf /usr/share/doc/openvpn
#      sed -i '/--dport 53 -j REDIRECT --to-port/d' /etc/rc.local
#      sed -i '/iptables -t nat -A POSTROUTING -s 10.8.0.0/d' /etc/rc.local
#      echo ""
#      echo "OpenVPN removed!"
#      exit
#      ;;
#      4) exit;;
#    esac
#  done
#else
#  echo 'Welcome to this quick OpenVPN "road warrior" installer'
#  echo ""
#  # OpenVPN setup and first user creation
#  echo "I need to ask you a few questions before starting the setup"
#  echo "You can leave the default options and just press enter if you are ok with them"
#  echo ""
#  echo "First I need to know the IPv4 address of the network interface you want OpenVPN"
#  echo "listening to."
#  read -p "IP address: " -e -i $IP IP
#  echo ""
#  echo "What port do you want for OpenVPN?"
#  read -p "Port: " -e -i 1194 PORT
#  echo ""
#  echo "Do you want OpenVPN to be available at port 53 too?"
#  echo "This can be useful to connect under restrictive networks"
#  read -p "Listen at port 53 [y/n]: " -e -i n ALTPORT
#  echo ""
#  echo "Finally, tell me your name for the client cert"
#  echo "Please, use one word only, no special characters"
#  read -p "Client name: " -e -i client CLIENT
#  echo ""
#  echo "Okay, that was all I needed. We are ready to setup your OpenVPN server now"
#  read -n1 -r -p "Press any key to continue..."
#  apt-get update
#  apt-get install openvpn iptables openssl -y
#  cp -R /usr/share/doc/openvpn/examples/easy-rsa/ /etc/openvpn
#  # easy-rsa isn't available by default for Debian Jessie and newer
#  if [ ! -d /etc/openvpn/easy-rsa/2.0/ ]; then
#    wget --no-check-certificate -O ~/easy-rsa.tar.gz https://github.com/OpenVPN/easy-rsa/archive/2.2.2.tar.gz
#    tar xzf ~/easy-rsa.tar.gz -C ~/
#    mkdir -p /etc/openvpn/easy-rsa/2.0/
#    cp ~/easy-rsa-2.2.2/easy-rsa/2.0/* /etc/openvpn/easy-rsa/2.0/
#    rm -rf ~/easy-rsa-2.2.2
#    rm -rf ~/easy-rsa.tar.gz
#  fi
#  cd /etc/openvpn/easy-rsa/2.0/
#  # Let's fix one thing first...
#  cp -u -p openssl-1.0.0.cnf openssl.cnf
#  # Fuck you NSA - 1024 bits was the default for Debian Wheezy and older
#  sed -i 's|export KEY_SIZE=1024|export KEY_SIZE=2048|' /etc/openvpn/easy-rsa/2.0/vars
#  # Create the PKI
#  . /etc/openvpn/easy-rsa/2.0/vars
#  . /etc/openvpn/easy-rsa/2.0/clean-all
#  # The following lines are from build-ca. I don't use that script directly
#  # because it's interactive and we don't want that. Yes, this could break
#  # the installation script if build-ca changes in the future.
#  export EASY_RSA="${EASY_RSA:-.}"
#  "$EASY_RSA/pkitool" --initca $*
#  # Same as the last time, we are going to run build-key-server
#  export EASY_RSA="${EASY_RSA:-.}"
#  "$EASY_RSA/pkitool" --server server
#  # Now the client keys. We need to set KEY_CN or the stupid pkitool will cry
#  export KEY_CN="$CLIENT"
#  export EASY_RSA="${EASY_RSA:-.}"
#  "$EASY_RSA/pkitool" $CLIENT
#  # DH params
#  . /etc/openvpn/easy-rsa/2.0/build-dh
#  # Let's configure the server
#  cd /usr/share/doc/openvpn/examples/sample-config-files
#  gunzip -d server.conf.gz
#  cp server.conf /etc/openvpn/
#  cd /etc/openvpn/easy-rsa/2.0/keys
#  cp ca.crt ca.key dh2048.pem server.crt server.key /etc/openvpn
#  cd /etc/openvpn/
#  # Set the server configuration
#  sed -i 's|dh dh1024.pem|dh dh2048.pem|' server.conf
#  sed -i 's|;push "redirect-gateway def1 bypass-dhcp"|push "redirect-gateway def1 bypass-dhcp"|' server.conf
#  sed -i "s|port 1194|port $PORT|" server.conf
#  # Obtain the resolvers from resolv.conf and use them for OpenVPN
#  cat /etc/resolv.conf | grep -v '#' | grep 'nameserver' | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | while read line; do
#    sed -i "/;push \"dhcp-option DNS 208.67.220.220\"/a\push \"dhcp-option DNS $line\"" server.conf
#  done
#  # Listen at port 53 too if user wants that
#  if [ $ALTPORT = 'y' ]; then
#    iptables -t nat -A PREROUTING -p udp -d $IP --dport 53 -j REDIRECT --to-port $PORT
#    sed -i "/# By default this script does nothing./a\iptables -t nat -A PREROUTING -p udp -d $IP --dport 53 -j REDIRECT --to-port $PORT" /etc/rc.local
#  fi
#  # Enable net.ipv4.ip_forward for the system
#  sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf
#  # Avoid an unneeded reboot
#  echo 1 > /proc/sys/net/ipv4/ip_forward
#  # Set iptables
#  iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to $IP
#  sed -i "/# By default this script does nothing./a\iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to $IP" /etc/rc.local
#  # And finally, restart OpenVPN
#  /etc/init.d/openvpn restart
#  # Let's generate the client config
#  mkdir ~/ovpn-$CLIENT
#  # Try to detect a NATed connection and ask about it to potential LowEndSpirit
#  # users
#  EXTERNALIP=$(wget -qO- ipv4.icanhazip.com)
#  if [ "$IP" != "$EXTERNALIP" ]; then
#    echo ""
#    echo "Looks like your server is behind a NAT!"
#    echo ""
#    echo "If your server is NATed (LowEndSpirit), I need to know the external IP"
#    echo "If that's not the case, just ignore this and leave the next field blank"
#    read -p "External IP: " -e USEREXTERNALIP
#    if [ $USEREXTERNALIP != "" ]; then
#      IP=$USEREXTERNALIP
#    fi
#  fi
#  # IP/port set on the default client.conf so we can add further users
#  # without asking for them
#  sed -i "s|remote my-server-1 1194|remote $IP $PORT|" /usr/share/doc/openvpn/examples/sample-config-files/client.conf
#  cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf ~/ovpn-$CLIENT/$CLIENT.conf
#  cp /etc/openvpn/easy-rsa/2.0/keys/ca.crt ~/ovpn-$CLIENT
#  cp /etc/openvpn/easy-rsa/2.0/keys/$CLIENT.crt ~/ovpn-$CLIENT
#  cp /etc/openvpn/easy-rsa/2.0/keys/$CLIENT.key ~/ovpn-$CLIENT
#  cd ~/ovpn-$CLIENT
#  sed -i "s|cert client.crt|cert $CLIENT.crt|" $CLIENT.conf
#  sed -i "s|key client.key|key $CLIENT.key|" $CLIENT.conf
#  tar -czf ../ovpn-$CLIENT.tar.gz $CLIENT.conf ca.crt $CLIENT.crt $CLIENT.key
#  cd ~/
#  rm -rf ovpn-$CLIENT
#  echo ""
#  echo "Finished!"
#  echo ""
#  echo "Your client config is available at ~/ovpn-$CLIENT.tar.gz"
#  echo "If you want to add more clients, you simply need to run this script another time!"
#fi
#
#


#forever-monitor

# var forever = require('forever-monitor');
#  var child = forever.start([ 'ssserver', '-c', '/root/ssocks/config.json' ], {
#    max : 1,
#    silent : false
#  });
#  var child = forever.start([ 'ssserver', '-c', '/root/ssocks/config.json.static' ], {
#    max : 1,
#    silent : false
#  });
#  var child = forever.start([ 'node', '/root/snova/server.js'  ], {
#    max : 1,
#    silent : false
#  });


#if.sh
#while true
#do
#NODE_PID=`pidof node`
#if [[ $NODE_PID == '' ]]; then
#echo node no running
#(cd /root/ssocks && ssserver)&
#sleep 1
#else
#echo node is running
#sleep 1
#fi
#done


#time.sh
#while true
#do
#
#if [[ `date +%H:%M` == '11:03' ]];then
#sudo reboot
#else
#sleep 1
#fi
## 5:01'clock,then reboot
#
#done