if [ ! -p /dev/stdin ]; then
  fatal "standard input not found"
fi

CLIENT_NAME="$(cat -)"

IP_FILE="$CACHE_DIR/ip/$CLIENT_NAME"
IP_DIR="$(dirname "$IP_FILE")"

debug "IP_DIR     : $IP_DIR"
debug "IP_FILE    : $IP_FILE"

mkdirp "$IP_DIR" || fatal "failed to create ip directory: $IP_DIR"

IP=''
if [ -f "$IP_FILE" ]; then
  IP="$(
    (
      ERR="$(cat "$IP_FILE">&3 2>&1)"
      if [ $? -ne 0 ]; then
        error "$ERR"
        fatal "failed to read previous ip address"
      fi
    ) 3>&1
  )"
fi

if [ -z "$IP" ]; then
  fatal "ip address not found"
fi

println "$IP"
