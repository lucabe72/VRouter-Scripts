VCPUAFFINITY=1
VHOSTAFFINITY=2

while getopts V:v: opt
 do
  echo "Opt: $opt"
  case "$opt" in
    v)		VCPUAFFINITY=$OPTARG;;
    V)		VHOSTAFFINITY=$OPTARG;;
    [?])	print >&2 "Usage: $0 [-v vcpu affinity]"
		exit 1;;
  esac
 done

tmp=`ps -e | grep qemu | head -n 1`
kvmpid=`echo $tmp | cut -d ' ' -f 1`
#vcpupid=`ps -e | grep qemu | head -n 2 | tail -n 1 | cut -d ' ' -f 3`
tmp=`ps ax | grep vhost- | head -n 1`
vhostpid=`echo $tmp | cut -d ' ' -f 1`
tmp=$(ls /proc/$kvmpid/task)
echo $tmp
vcpupid=$(echo $tmp | cut -d ' ' -f 3)
echo $vcpupid

#sudo chrt -f -p 99 $vcpupid
sudo taskset -p $VCPUAFFINITY $vcpupid

sudo chrt -f -p 99 $vhostpid
sudo taskset -p $VHOSTAFFINITY $vhostpid
sudo taskset -p $VHOSTAFFINITY $kvmpid
#sudo taskset -p 2 $vcpupid
#echo 02 > /proc/irq/$ETH1IRQRX/smp_affinity
#echo 02 > /proc/irq/$ETH1IRQTX/smp_affinity
#pid=`ps ax | grep vhost- | head -n 2 | tail -n 1 | cut -d ' ' -f 2`
#sudo chrt -f -p 95 $pid
