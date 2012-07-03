MYSELF=$USER
LIST=$(ip link show | grep macvtap | cut -d ':' -f 1)

sudo /sbin/modprobe kvm_intel

sudo chown $MYSELF /dev/kvm
sudo chown $MYSELF /dev/vhost-net
for TAP_N in $LIST
 do
  sudo chown $MYSELF /dev/tap$TAP_N
 done
