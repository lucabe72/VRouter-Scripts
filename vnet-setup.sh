#IFN=0
BASE=0
MODE="mode bridge"
ZCOPY=""
ETH1_IP="NoThanks"
HOST_BRIDGE="macvtap"
QLEN=1000 #FIXME!
MAC_PREFIX=00:16:35:AF:94:4
N_IF=1

eth_setup() {
  if test $ETH1_IP = NoThanks;
   then
    sudo ip link set dev $1 up
   else
    sudo ip addr add $ETH1_IP/24 dev $1 
   fi
  sudo ethtool -A $1 autoneg off rx off tx off
}

virt_lan_setup() {
#  MYSELF=$USER
#  sudo /usr/sbin/tunctl -u $MYSELF -b -t $1
  sudo ip link add name $1 type dummy
  sudo ip link set dev $1 up
}

macvtap_create_n() {
  sudo /sbin/modprobe macvtap
  sudo /sbin/modprobe vhost-net $ZCOPY

  for i in $1
   do
    sudo ip link add link $2 name macvtap$i type macvtap $MODE
    sudo ip link set dev macvtap$i address $MAC_PREFIX$i
    sudo ip link set dev macvtap$i up
#    sudo /sbin/ifconfig macvtap$i txqueuelen $QLEN
#    sudo ip link set dev macvtap$i txqueuelen $QLEN
  done
}

bridge_create() {
  MYSELF=$USER
  sudo /sbin/modprobe vhost-net $ZCOPY

#  sudo /sbin/brctl addbr $2
  sudo ip link add name $2 type bridge
  sudo ip link set dev $2 up
  for i in $1
   do
#    sudo /usr/sbin/tunctl -u $MYSELF -b -t tap$i
    sudo ip tuntap add dev tap$i mode tap user $MYSELF
#    sudo /sbin/brctl addif br0 tap$i
    sudo ip link set dev tap$i master $2
#    sudo /sbin/ifconfig tap$i 0.0.0.0 promisc
    sudo ip link set dev tap$i promisc on
    sudo ip link set dev tap$i up 
   done
}

bridge_add_iface() {
  for i in $1
   do
    sudo ip link set dev eth$i master $2
    sudo ip link set dev eth$i promisc on
    sudo ip link set dev eth$i up
   done
}

while getopts i:zvpPbB:I:n:V:m: opt
 do
  echo "Opt: $opt"
  case "$opt" in
    V)		VIRT_LAN=$OPTARG;;
    v)		MODE="mode vepa";;
    p)		MODE="mode private";;
    P)		MODE="mode passthru";;
    b)		MODE="mode bridge";;
    z)		ZCOPY="experimental_zcopytx=1";;
    B)		HOST_BRIDGE="bridge";BRIF=$OPTARG;;
    i)		ETH1_IP=$OPTARG;;
    I)		IFN=$OPTARG;;
    n)		N_IF=$OPTARG;;
    m)		BASE=$OPTARG;;
    [?])	print >&2 "Usage: $0 [-v] [-p] [-P] [-b]"
		exit 1;;
  esac
 done

echo VL: $VIRT_LAN
I_LIST=$(seq $BASE $(($BASE + $N_IF - 1)))

if test x$HOST_BRIDGE = xmacvtap; then
  if test x$IFN = x;
   then
    echo "MACVTAP without virtual switch needs a network interface! Use \"-I\""
    exit
   fi
  if test x$VIRT_LAN = x;
   then
    eth_setup eth$IFN
    IF=eth$IFN
   else
    echo Virt Lan $VIRT_LAN
    virt_lan_setup $VIRT_LAN
    IF=$VIRT_LAN
   fi
  echo MACVTAP, $N_IF interfaces!
  macvtap_create_n "$I_LIST" $IF
 elif test x$HOST_BRIDGE = xbridge; then
  echo BRIDGE!
  bridge_create "$I_LIST" $BRIF
  bridge_add_iface "$IFN" $BRIF
 else
  echo Unknown host bridge type $HOST_BRIDGE
 fi
