# Setup Spirit Router
bash <<EOF2
sed -i 's/localhost/spiritrouter/g' /etc/hostname
sed -i 's/localhost/spiritrouter/g' /etc/hosts
hostname spiritrouter
apk add bird --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing
rc-update add bird
cat >> /etc/network/interfaces << EOF 
auto eth1
iface eth1 inet static
   address 10.40.243.2
   netmask 255.255.255.128
EOF
/etc/init.d/networking restart
cat > /etc/bird.conf << EOF1
# Configure logging
log syslog all;
log stderr all;

# Override router ID
router id 10.40.243.2;

# Define haproxy AS variable
define haproxyas = 64705;

# Define spirit AS variable
define spiritas = 65516;

filter clients_vip {
 if net ~ 172.16.2.0/24 then accept;
 else reject;
}

protocol kernel {
 scan time 2;
 ipv4 {
        import all;
        export all;
 };
 learn;
}

protocol device {
 scan time 2;
}

protocol direct {
 interface "eth1";
}

protocol bgp reflector1 {
 local as spiritas;
 export none;
 import all;
 allow bgp_local_pref;
 source address 10.40.243.2;
 neighbor 10.40.243.4 as haproxyas;
}

protocol bgp reflector2 {
 local as spiritas;
 export none;
 import all;
 allow bgp_local_pref;
 source address 10.40.243.2;
 neighbor 10.40.243.5 as haproxyas;
}
EOF1
exit
EOF2