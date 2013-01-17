export PATH=$PATH:/home/$USER/bin

sh vnet-setup.sh -I 0 -z
sh vnet-setup.sh -B internal -z -m 1 -n 2
sh setkvm.sh
