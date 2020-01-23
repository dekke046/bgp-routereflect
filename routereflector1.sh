# Setup Route Reflector 1
bash <<EOF2
sed -i 's/localhost/reflector1/g' /etc/hostname
sed -i 's/localhost/reflector1/g' /etc/hosts
hostname reflector1
apk add bird --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing
rc-update add bird
cat >> /etc/network/interfaces << EOF 
auto eth1
iface eth1 inet static
   address 10.40.243.4
   netmask 255.255.255.128
EOF
/etc/init.d/networking restart
cat > /etc/bird.conf << EOF1 
# Configure logging
log syslog { debug, trace, info, remote, warning, error, auth, fatal, bug };
log stderr all;
# Override router ID
router id 10.40.243.4;

# Define local AS variable
define haproxyas = 64705;

# Define spirit AS variable
define spiritas = 65516;


# Sync bird routing table with kernel
protocol kernel {
	ipv4 {
			export all;
		};
}

protocol device {
        scan time 2;
}

# Include directly connected networks
protocol direct {
        interface "eth1";
}

protocol bgp haproxy11 {
 local as haproxyas;
 neighbor 10.40.243.9 as haproxyas;
 ipv4 {
		import all;
		export all;
	};
 rr client;
}

protocol bgp haproxy21 {
 local as haproxyas;
 neighbor 10.40.243.10 as haproxyas;
 ipv4 {
		import all;
		export all;
	};
 rr client;
}


protocol bgp router1 {
ipv4 {
		import none;
		export all;
	};
 local as haproxyas;
 source address 10.40.243.4;
 neighbor 10.40.243.3 as spiritas;
 # Override the usual restriction of LOCAL_PREF on eBGP sessions
 allow bgp_local_pref;
}

EOF1
exit
EOF2