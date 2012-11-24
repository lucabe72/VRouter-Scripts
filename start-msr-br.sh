#sh starttiny-macvtap.sh -K -n -v 1 -i "macvtap0 macvtap1" &
sh starttiny-macvtap.sh -k -n -v 1 -i "macvtap0" -I "tap1" -o /home/luca/MSR/opt2.img -l /home/luca/MSR/bzImage -c /home/luca/MSR/core.gz </dev/zero &>log-lb1.txt &
sleep 5
sh starttiny-macvtap.sh -k -n -v 2 -i "" -I "tap2" </dev/zero &>log-br1.txt &
sleep 5
