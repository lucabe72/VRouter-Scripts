#!/bin/bash

get_tap_n() {
  num=$(ip link show | grep tap | grep -v macvtap | wc -l)  
  RES=""
  for i in 0..$num
   do
    N=$(ip link show | grep tap | cut -d ':' -f 2)
    RES="$RES $N"
   done
  echo $RES
}

get_macvtap_n() {
  num=$(ip link show | grep macvtap | wc -l)   
  RES=""
  for i in 0..$num
   do
    N=$(ip link show | grep macvtap | cut -d ':' -f 2 | cut -d '@' -f 1)
    RES="$RES $N"
   done
  echo $RES
}

del_tap_n(){
for i in $1
  do
     tunctl -d $i 
  done
}


del_macvtap_n(){
for i in $1
  do
     ip link del $i
  done
}

del_bridge_n(){
for i in $bridge_name
  do
     ifconfig $i down
     brctl delbr $i
  done
}

while getopts b: opt
 do
  echo "Opt: $opt"
  case "$opt" in
    b)		bridge_name=$OPTARG;;
    [?])	print >&2 "Usage: $0 [-b]"
		exit 1;;
  esac
 done

#if (($# != 1))
#then
#echo "Usage: $0 [-b]"
#exit 1
#fi

TAP_N=$(get_tap_n);
MACVTAP_N=$(get_macvtap_n);


del_tap_n "$TAP_N";
del_macvtap_n "$MACVTAP_N";
del_bridge_n;

