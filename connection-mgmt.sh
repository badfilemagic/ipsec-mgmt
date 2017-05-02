# (C) 2017, W. Dean Freeman, CISSP CSSLP GCIH
# v0.1 
# Append this to your ~/.bashrc
# Requires that you install rand (sudo apt-get install rand)
# StrongSwan or similar should be an obvious dependency...
# 
# Connect/disconnect to random IKEv2/IPsec endpoint from list configured in /etc/ipsec.conf
# Cycle vpn connections
# Disable/re-enable ivp6 to avoid leakage

IPSEC=/usr/sbin/ipsec
RAND=/usr/bin/rand
export VPN=""
vpn_up()
{
        if [ "$1" != ""]; then
		VPN=$1
	else	
		random_vpn
	fi
        sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
        sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
        sudo $IPSEC up $VPN
}
vpn_down()
{
	if [ "$VPN" == "" ]; then
		VPN=`cat /tmp/vpn_conn`
	fi
	sudo $IPSEC down $VPN
        sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0
        sudo sysctl -w net.ipv6.conf.default.disable_ipv6=0
}
vpn_cycle()
{
        vpn_down
        vpn_up
}
list_vpns()
{
        grep ^conn /etc/ipsec.conf | awk '{print $2}'
}
random_vpn()
{
        VPNS=(`list_vpns`)
        n=`list_vpns | wc -l`
        i=`$RAND -M $n`
        VPN=${VPNS[$i]}
	echo $VPN > /tmp/vpn_conn
}
