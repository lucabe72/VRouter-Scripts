VCPUAFFINITY=1
VHOSTAFFINITY=2
VCPUPRIORITY=99
VHOSTPRIORITY=99


while getopts V:v:P:p:f: opt
 do
  echo "Opt: $opt"
  case "$opt" in
    v)		VCPUAFFINITY=$OPTARG;;
    V)		VHOSTAFFINITY=$OPTARG;;
    p)		VCPUPRIORITY=$OPTARG;;
    P)		VHOSTPRIORITY=$OPTARG;;
    f)		FILTER=$OPTARG;;
    [?])	echo >&2 "Usage: $0"\
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
  sudo chrt -f -p $VCPUPRIORITY $vcpupid
  sudo taskset -p $VCPUAFFINITY $vcpupid
 done

for vhostpid in $vhostpids
 do
  sudo chrt -f -p $VHOSTPRIORITY $vhostpid
  sudo taskset -p $VHOSTAFFINITY $vhostpid
 done

for kvmpid in $kvmpids
 do
  sudo chrt -f -p $VHOSTPRIORITY $kvmpid
  sudo taskset -p $VHOSTAFFINITY $kvmpid
 done
