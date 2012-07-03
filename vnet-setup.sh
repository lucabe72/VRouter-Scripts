IFN=0
MODE="mode bridge"
ZCOPY=""
ETH1_IP="NoThanks"
HOST_BRIDGE="macvtap"
QLEN=20000 #FIXME!
MACADDR=00:16:35:AF:94:40
MAC_PREFIX=00:16:35:AF:94:4
N_IF=1

macvtap_create() {
  sudo /sbin/modprobe macvtap
  sudo /sbin/modprobe vhost-net $ZCOPY

  sudo ip link add link eth$IFN name macvtap0 type macvtap $MODE
  sudo ip link set macvtap0 address $MACADDR 
  sudo /sbin/ifconfig macvtap0 up
  sudo /sbin/ifconfig macvtap0 txqueuelen $QLEN
}

macvtap_create_n() {
  sudo /sbin/modprobe macvtap
  sudo /sbin/modprobe vhost-net $ZCOPY

  for i in $1
   do
    sudo /sbin/ip link add link eth$IFN name macvtap$i type macvtap $MODE
    sudo /sbin/ip link set macvtap$i address $MAC_PREFIX$i
    sudo /sbin/ifconfig macvtap$i up
    sudo /sbin/ifconfig macvtap$i txqueuelen $QLEN
  done
}

bridge_create() {
  sudo /sbin/brctl addbr br0
  sudo /usr/sbin/tunctl -u luca -b -t tap0
  sudo /sbin/brctl addif br0 eth$IFN
  sudo /sbin/brctl addif br0 tap0
  sudo /sbin/ifconfig eth$IFN 0.0.0.0 promisc
  sudo /sbin/ifconfig tap0 0.0.0.0 promisc
  sudo /sbin/ifconfig br0 192.168.1.2
}

while getopts izvpPbB2I:n: opt
 do
  echo "Opt: $opt"
  case "$opt" in
    v)		MODE="mode vepa";;
    p)		MODE="mode private";;
    P)		MODE="mode passthru";;
    b)		MODE="mode bridge";;
    z)		ZCOPY="experimental_zcopytx=1";;
    B)		HOST_BRIDGE="bridge";;
    2)		HOST_BRIDGE="macvtap2";;
    i)		ETH1_IP="YesPlease";;
    I)		IFN=$OPTARG;;
    n)		N_IF=$OPTARG;;
    [?])	print >&2 "Usage: $0 [-v] [-p] [-P] [-b]"
		exit 1;;
  esac
 done

if test $ETH1_IP = YesPlease;
 then
  sudo /sbin/ifconfig eth$IFN 192.168.1.2
 else
  sudo /sbin/ifconfig eth$IFN 0.0.0.0 
 fi
sudo ethtool -A eth$IFN autoneg off rx off tx off

if test x$HOST_BRIDGE = xmacvtap; then
  echo MACVTAP, $N_IF interfaces!
  I_LIST=$(seq 0 $(($N_IF - 1)))
  macvtap_create_n "$I_LIST"
 elif test x$HOST_BRIDGE = xbridge; then
  echo BRIDGE!
  bridge_create
 elif test x$HOST_BRIDGE = xmacvtap2; then
  echo MACVTAP2!
  macvtap_create_n "0 1"
 else
  echo Unknown host bridge type $HOST_BRIDGE
 fi
