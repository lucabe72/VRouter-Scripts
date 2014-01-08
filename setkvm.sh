MYSELF=$USER
LIST=$(ip link show | grep macvtap | cut -d ':' -f 1)

#
# load the proper kvm kernel module...
#

load_kvm()
{
    INTEL=kvm_intel
    AMD=kvm_amd

    if [ ! -z "`grep "vendor_id.*GenuineIntel" /proc/cpuinfo`" ]; then
        echo -n "Intel CPU detected: "
        KMODULE=$INTEL
    elif [ ! -z  "`grep "vendor_id.*AuthenticAMD" /proc/cpuinfo`" ]; then
        echo -n "AMD CPU detected: "
        KMODULE=$AMD
    else 
        echo -n "Error: CPU type not supported! ("
        echo "`grep -m 1 vendor_id /proc/cpuinfo`)"
        exit 1
    fi
        
    echo "loading $KMODULE..."
    sudo /sbin/modprobe $KMODULE $*
}

load_kvm
 
sudo chown $MYSELF /dev/kvm
sudo chown $MYSELF /dev/vhost-net
sudo chown $MYSELF /dev/tun
for TAP_N in $LIST
 do
  sudo chown $MYSELF /dev/tap$TAP_N
 done

echo "done."
