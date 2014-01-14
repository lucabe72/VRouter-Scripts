TAPS=$(ip link show | grep tap | cut -d ':' -f 2 | cut -d '@' -f 1)

echo $TAPS

for D in $TAPS
 do
  sudo /home/vrouter/bin/ip link del $D
 done

for D in $1
 do
  sudo /home/vrouter/bin/ip link del $D
 done
