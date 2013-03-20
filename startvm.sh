#export LD_LIBRARY_PATH=/home/luca/lib32
export LD_LIBRARY_PATH=$(pwd)/../lib64:$(pwd)/../lib
NETCARD=virtio-net-pci 
VHOST=""
KVM=-enable-kvm
CPU=""
EMUL=$(pwd)/../Public-Qemu-Test/bin/qemu-system-i386
TRM="-curses"
APPEND="nodhcp nozswap opt=sda1 user=vrouter home=sda1 waitusb=5"
IFACES="macvtap0"
KERNEL=Core/boot/vmlinuz
CORE=Core/boot/core.gz
GUEST_IMG=""
TUNTAP=""
OPT="opt1.img"

echo $APPEND

build_machinecfg() {
  CPU=$1
  CFG=""

  CFG="$CFG -m 512 -machine type=pc,accel=kvm"
  if test x$CPU != x;
   then
    CFG="$CFG -cpu $CPU"
   fi

  echo $CFG
}

build_netcfg_macvtap() {
  CFG=""
  FD=3
  for i in $1
   do
    MACADDR=$(echo $(ip link show | grep -A 1 "^$i: " | tail -n 1) | cut -d ' ' -f 2)
    CFG="$CFG -netdev tap,id=nic$i,fd=$FD$VHOST"
    CFG="$CFG -device $NETCARD,netdev=nic$i,mac=$MACADDR"
    FD=$(($FD + 1))
   done

  echo $CFG
}

build_netcfg_tuntap() {
  CFG=""

  for i in $1
   do
    ID=$(echo ${i##*[a-z]})
    MACADDR=00:16:35:AF:94:4$ID
    CFG="$CFG -netdev tap,id=tapnic$i,ifname=$i,script=no,downscript=no$VHOST"
    CFG="$CFG -device $NETCARD,netdev=tapnic$i,mac=$MACADDR"
   done

  echo $CFG
}

build_netcfg_netmap() {
CFG=""
  for i in $1
   do
    ID=$(echo ${i##*[a-z]})
    MACADDR=00:16:35:AF:94:4$ID
    #CFG="$CFG -net nic,model=$NETCARD,macaddr=$MACADDR -net netmap,ifname=$i"
    CFG="$CFG -netdev netmap,id=netmap$i,ifname=$i"
    CFG="$CFG -device $NETCARD,netdev=netmap$i,mac=$MACADDR"
   done

  echo $CFG
}

build_redir() {
  REDIR=""
  FD=3
  for i in $1
   do
    REDIR="$REDIR $FD<>/dev/tap$i"
    FD=$(($FD + 1))
   done

  echo $REDIR
}

get_tap_n() {
  RES=""
  for i in $1
   do
    N=$(ip link show | grep $i | cut -d ':' -f 1)
    RES="$RES $N"
   done
  echo $RES
}

cardinality() {
  N=0
  for i in $1
   do
    N=$((N + 1))
   done
  echo $N
}

get_n() {
  N=0
  for i in $1
   do
    N=$((N + 1))
    if test $N = $2
     then
      echo $i
     fi
   done
}

while getopts v:tkKnNei:l:c:g:C:E:o:I:p: opt
 do
  echo "Opt: $opt"
  case "$opt" in
    e)		NETCARD=e1000;;
    n)		VHOST=,vhost=on;;
    N)		KVM="";;
    C)		CPU=$OPTARG;;
    E)		EMUL=$OPTARG;;
    k)		EMUL=$(pwd)/../Public-KVM-Test/bin/qemu-system-x86_64;;
    K)		EMUL=$(pwd)/../Public-KVM-Test64/bin/qemu-system-x86_64;;
    t)		TRM="-curses";;
    v)		TRM="-vnc :$OPTARG";;
    i)		IFACES=$OPTARG;;
    I)		TUNTAP=$OPTARG;;
    l)		KERNEL=$OPTARG;;
    c)		CORE=$OPTARG;;
    g)		GUEST_IMG=$OPTARG;;
    o)		OPT=$OPTARG;;
    p)          NETMAPBASE=$OPTARG;;
    [?])	print >&2 "Usage: $0 [-e] [-n] [-N] [-k]"
		exit 1;;
  esac
 done

#MACADDR=$(echo $(ip link show | grep -A 1 $TAP_N: | tail -n 1) | cut -d ' ' -f 2)
#echo MAC: $MACADDR

TAP_N=$(get_tap_n "$IFACES")
MACHINECFG=$(build_machinecfg "$CPU")
NETCFG=$(build_netcfg_macvtap "$TAP_N")
NETCFG1=$(build_netcfg_tuntap "$TUNTAP")
NETCFG2=$(build_netcfg_netmap "$NETMAPBASE")
REDIR=$(build_redir "$TAP_N")

if test x$GUEST_IMG = x;
 then
  GUEST_CMD="-kernel $KERNEL -initrd $CORE -hda $OPT -append \"$APPEND\""
 else
  GUEST_CMD="-hda $GUEST_IMG"
 fi
CMD="$MACHINECFG $NETCFG $NETCFG1 $NETCFG2 $KVM $TRM"

eval "$EMUL $GUEST_CMD $CMD $REDIR"
