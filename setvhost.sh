VCPUAFFINITY=1
VHOSTAFFINITY=2
VCPUPRIORITY=99
VHOSTPRIORITY=99


while getopts q:t:Q:T:V:v:P:p:f:h opt
 do
  echo "Opt: $opt"
  case "$opt" in
    q)		VCPUBUDGET=$OPTARG;;
    t)		VCPUPERIOD=$OPTARG;;
    Q)		VHOSTBUDGET=$OPTARG;;
    T)		VHOSTPERIOD=$OPTARG;;
    v)		VCPUAFFINITY=$OPTARG;;
    V)		VHOSTAFFINITY=$OPTARG;;
    p)		VCPUPRIORITY=$OPTARG;;
    P)		VHOSTPRIORITY=$OPTARG;;
    f)		FILTER=$OPTARG;;
    [h?])	echo >&2 "Usage: $0"\
    		" [-q vcpu maximum budget]"\
    		" [-t vcpu server period]"\
    		" [-Q vhost maximum budget]"\
    		" [-T vhost server period]"\
    		" [-v vcpu affinity]"\
    		" [-V vhost affinity]"\
    		" [-p vcpu priority]"\
    		" [-P vhost priority]"\
    		""
    		echo >&2 " example: $0 -f opt2 -v 4 -V 8 -p 99 -P 98"
    		exit 1;;
  esac
 done

kvmpids=`ps -e | grep [q]emu | grep "$FILTER" | cut -c 1-6`
echo kvm PIDs: $kvmpids
for kvmpid in $kvmpids
 do
  vhostpids="$vhostpids "`ps ax | grep [v]host-$kvmpid | cut -c 1-6`
  tmp=$(ls /proc/$kvmpid/task)
  vcpupids="$vcpupids "$(echo $tmp | cut -d ' ' -f 2)
 done

echo vhost PIDs: $vhostpids
echo vcpu PIDs: $vcpupids

for vcpupid in $vcpupids
 do
  AFF=$(echo $VCPUAFFINITY | cut -d ' ' -f 1)
  sudo taskset -p $AFF $vcpupid
  VCPUAFFINITY=$(echo $VCPUAFFINITY | cut -d ' ' -f 2-)
  if [ x$VCPUBUDGET = x ]
   then
    if [ $VCPUPRIORITY = "0" ];
     then
      sudo chrt -o -p 0 $vcpupid
     else
      sudo chrt -f -p $VCPUPRIORITY $vcpupid
     fi
   else
    chdl $vcpupid $VCPUBUDGET $VCPUPERIOD
   fi
 done

for vhostpid in $vhostpids
 do
  AFF=$(echo $VHOSTAFFINITY | cut -d ' ' -f 1)
  sudo taskset -p $AFF $vhostpid
  VHOSTAFFINITY=$(echo $VHOSTAFFINITY | cut -d ' ' -f 2-)
  if [ x$VHOSTBUDGET = x ]
   then
    if [ $VHOSTPRIORITY = "0" ];
     then
      sudo chrt -o -p 0 $vhostpid
     else
      sudo chrt -f -p $VHOSTPRIORITY $vhostpid
     fi
   else
    chdl $vhostpid $VHOSTBUDGET $VHOSTPERIOD
   fi
 done

#for kvmpid in $kvmpids
# do
#  sudo chrt -f -p $VHOSTPRIORITY $kvmpid
#  sudo taskset -p $VHOSTAFFINITY $kvmpid
# done
