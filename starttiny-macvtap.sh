#export LD_LIBRARY_PATH=/home/luca/lib32
export LD_LIBRARY_PATH=$(pwd)/../lib
NETCARD=virtio-net-pci 
VHOST=""
KVM=-enable-kvm
EMUL=$(pwd)/../Public-Qemu-Test/bin/qemu-system-i386
TRM="-vnc :1"
APPEND="nodhcp nozswap opt=sda1"
IFACES="macvtap0"
KERNEL=Core/boot/vmlinuz
CORE=Core/boot/core.gz
GUEST_IMG=""

echo $APPEND

build_netcfg() {
  CFG=""
  FD=3
  for i in $1
   do
    MACADDR=$(echo $(ip link show | grep -A 1 "$i: " | tail -n 1) | cut -d ' ' -f 2)
    CFG="$CFG -netdev tap,id=nic$i,fd=$FD$VHOST"
    CFG="$CFG -device $NETCARD,netdev=nic$i,mac=$MACADDR"
    FD=$(($FD + 1))
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

while getopts vtkKnNei:l:c:g: opt
 do
  echo "Opt: $opt"
  case "$opt" in
    e)		NETCARD=e1000;;
    n)		VHOST=,vhost=on;;
    N)		KVM="";;
    k)		EMUL=$(pwd)/../Public-KVM-Test/bin/qemu-system-x86_64;;
    K)		EMUL=$(pwd)/../Public-KVM-Test64/bin/qemu-system-x86_64;;
    t)		TRM="-curses";;
    v)		TRM="-vnc :1";;
    i)		IFACES=$OPTARG;;
    l)		KERNEL=$OPTARG;;
    c)		CORE=$OPTARG;;
    g)		GUEST_IMG=$OPTARG;;
    [?])	print >&2 "Usage: $0 [-e] [-n] [-N] [-k]"
		exit 1;;
  esac
 done

#MACADDR=$(echo $(ip link show | grep -A 1 $TAP_N: | tail -n 1) | cut -d ' ' -f 2)
#echo MAC: $MACADDR

TAP_N=$(get_tap_n "$IFACES")
NETCFG=$(build_netcfg "$TAP_N")
REDIR=$(build_redir "$TAP_N")

if test x$GUEST_IMG = x;
 then
  GUEST_CMD="-kernel $KERNEL -initrd $CORE -hda opt1.img -append \"$APPEND\""
 else
  GUEST_CMD="-hda $GUEST_IMG"
 fi
CMD="-m 512 -machine type=pc-1.1,accel=kvm,kernel_irqchip=on -cpu kvm32 $NETCFG $KVM $TRM"

eval "$EMUL $GUEST_CMD $CMD $REDIR"
