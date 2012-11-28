#sh startvm.sh -K -n -v 1 -i "macvtap0 macvtap1" &
sh startvm.sh -k -n -v 1 -i "macvtap0" -I "tap1" -o opt2.img -l Core/boot/vmlinuz-lb -c Core/boot/core-lb.gz </dev/zero &>log-lb1.txt &
sleep 5
sh startvm.sh -k -n -v 2 -i "" -I "tap2" </dev/zero &>log-br1.txt &
sleep 5
