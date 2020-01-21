# Setup Route Reflector 1
bash <<EOF2
sed -i 's/ubuntu/reflector2/g' /etc/hostname
sed -i 's/ubuntu/reflector2/g' /etc/hosts
hostname reflector2
add-apt-repository -y ppa:cz.nic-labs/bird
apt-get update
apt-get install bird traceroute
cat >> /etc/network/interfaces << EOF 
auto enp0s8
iface enp0s8 inet static
   address 10.40.243.5
   netmask 255.255.255.128
EOF
/etc/init.d/networking restart
cat > /etc/bird/bird.conf << EOF1 
# Configure logging
log syslog { debug, trace, info, remote, warning, error, auth, fatal, bug };
log stderr all;
# Override router ID
router id 10.40.243.5;

# Define local AS variable
define haproxyas = 64705;

# Define spirit AS variable
define spiritas = 65516;


# Sync bird routing table with kernel
protocol kernel {
        export all;
}

protocol device {
        scan time 2;
}

# Include directly connected networks
protocol direct {
        interface "enp0s8";
}

protocol bgp haproxy12 {
 local as haproxyas;
 neighbor 10.40.243.11 as haproxyas;
 import all;
 export all;
 rr client;
}

protocol bgp haproxy22 {
 local as haproxyas;
 neighbor 10.40.243.12 as haproxyas;
 import all;
 export all;
 rr client;
}

protocol bgp router1 {
 import none;
 export all;
 local as haproxyas;
 source address 10.40.243.5;
 neighbor 10.40.243.3 as spiritas;
 # Override the usual restriction of LOCAL_PREF on eBGP sessions
 allow bgp_local_pref;
}

EOF1
exit
EOF2