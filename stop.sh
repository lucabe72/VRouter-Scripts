CMDLINE=$(ps ax | grep qemu | grep "vnc :$1")
PID=$(echo $CMDLINE | cut -f 1 -d ' ')
echo PID: $PID
kill $PID
