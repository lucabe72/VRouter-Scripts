export PATH=$PATH:/home/$USER/bin

if test x$1 = x; then
  echo "Specify the interface number!!!"
  exit
fi

#FIXME: Make this configurable!!!
VCPUAFF="-v 0x0f"
RXAFF="-r 1"
TXAFF="-t 2"

sh vnet-setup.sh -z -I $1
sh setkvm.sh
sudo ethtool -A eth$1 autoneg off rx off tx off
sh startvm.sh -k -n -v &
sleep 5
sync
sh setvhost.sh $VCPUAFF
sudo sh setirq.sh -i $1 $RXAFF $TXAFF
#sudo /sbin/ifconfig eth$1 txqueuelen 50000
#sudo /sbin/ifconfig macvtap0 txqueuelen 90000
sudo ethtool -A eth$1 autoneg off rx off tx off
