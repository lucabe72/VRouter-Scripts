ETH=eth0
TX_AFF=2
RX_AFF=1
#TX_AFF=3
#RX_AFF=3

get_irqs() {
  irqs=$(grep $1 /proc/interrupts | cut -d ':' -f 1)
  echo $irqs
}

set_affinity() {
  for i in $1
   do
    echo $2 > /proc/irq/$i/smp_affinity
   done
}

while getopts i:t:r: opt
 do
  echo "Opt: $opt"
  case "$opt" in
    i)		ETH=eth$OPTARG;;
    t)		TX_AFF=$OPTARG;;
    r)		RX_AFF=$OPTARG;;
    [?])	print >&2 "Usage: $0 [-r rx affinity] [-t tx affinity]"
		exit 1;;
  esac
 done

echo RX: $RX_AFF TX: $TX_AFF
tx_irqs=$(get_irqs $ETH-tx)
rx_irqs=$(get_irqs $ETH-rx)
eth_irqs=$(get_irqs $ETH)
if test x$tx_irqs = x; then
  echo No separate TX queue!
  set_affinity "$eth_irqs" 1
 else
  echo Separate TX queue!
  set_affinity "$tx_irqs" $TX_AFF 
  set_affinity "$rx_irqs" $RX_AFF
 fi

#res1=$(get_irqs uhci)
#
#set_affinity "$res" 1
#set_affinity "$res1" 2
