# Setup Haproxy-2-2
bash <<EOF2
sed -i 's/ubuntu/haproxy22/g' /etc/hostname
sed -i 's/ubuntu/haproxy22/g' /etc/hosts
hostname haproxy22
add-apt-repository -y ppa:cz.nic-labs/bird
apt-get update
apt-get install bird traceroute
cat >> /etc/network/interfaces << EOF 
auto enp0s8
iface enp0s8 inet static
   address 10.40.243.12
   netmask 255.255.255.128
auto lo:0
  iface lo:0 inet static
  address 172.16.2.12
  netmask 255.255.255.255
EOF
/etc/init.d/networking restart
cat > /etc/bird/bird.conf << EOF1 
# Configure logging
log syslog all;
log "/var/log/bird.log" all;
log stderr all;

# Override router ID
router id 10.40.243.12;

# Define local AS variable
define haproxyas = 64705;

# VIP's which we want to announce
protocol static VIPs {
 route 172.16.2.12/32 via 10.40.243.12;
}

# Sync bird routing table with kernel
protocol kernel {
 export all;
}

# Include device route (warning, a device route is a /32)
protocol device {
 scan time 2;
}

# Include directly connected networks
protocol direct {
 interface "enp0s8";
}

protocol bgp reflector1 {
 local as haproxyas;
 neighbor 10.40.243.4 as haproxyas;
 default bgp_local_pref 200;
 import all;
 export all;
}
EOF1
exit
EOF2