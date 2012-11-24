VMs=$1

i=0
while [ $i -lt $VMs ]
 do 
  nohup sh starttiny-macvtap.sh -k -n -v $i -i "macvtap0" 2>&1 &
  sleep 5
  i=`expr $i + 1`
 done
