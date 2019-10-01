IP="$(echo $SSH_CLIENT | sed -e 's/ .*$//g')"

if [ -z "$IP" ]; then
  fatal "ip address not found"
fi

println "$IP"
