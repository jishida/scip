if [ ! -p /dev/stdin ]; then
  fatal "standard input not found"
fi

CLIENT_NAME="$(cat -)"

IP_FILE="$CACHE_DIR/ip/$CLIENT_NAME"
IP_DIR="$(dirname "$IP_FILE")"

debug "IP_DIR     : $IP_DIR"
debug "IP_FILE    : $IP_FILE"

mkdirp "$IP_DIR" || fatal "failed to create ip directory: $IP_DIR"

PREV_IP=''
if [ -f "$IP_FILE" ]; then
  PREV_IP="$(
    (
      ERR="$(cat "$IP_FILE">&3 2>&1)"
      if [ $? -ne 0 ]; then
        error "$ERR"
        fatal "failed to read previous ip address"
      fi
    ) 3>&1
  )"
fi

CLIENT_IP="$(echo $SSH_CLIENT | sed -e 's/ .*$//g')"
if [ "$CLIENT_IP" = "$PREV_IP" ]; then
  debug "up-to-date($CLIENT_NAME): $CLIENT_IP"
else
  OUTPUT="$( (echo "$CLIENT_IP">"$IP_FILE") 2>&1)"
  if [ $? -ne 0 ]; then
    error "$OUTPUT"
    fatal "failed to write client ip address($CLIENT_NAME): $CLIENT_IP"
  fi
  info "updated ip address($CLIENT_NAME): $CLIENT_IP"
fi
