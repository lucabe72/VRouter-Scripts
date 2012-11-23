
sh vnet-setup.sh -I 0 -z
sh vnet-setup.sh -V internal -z -m 1 -n 2
#sudo ip link set macvtap1 address 68:05:ca:02:c7:11
sudo ip link set macvtap1 address 14:fe:b5:fb:c3:97
sh setkvm.sh
