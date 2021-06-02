#!/bin/bash

# Add standard config items
cat <<END >>$RIAK_CONF
nodename = $CLUSTER_NAME@$HOST
distributed_cookie = $CLUSTER_NAME
listener.protobuf.internal = $HOSTIP:$PB_PORT
listener.http.internal = $HOSTIP:$HTTP_PORT
mdc.cluster_manager = $HOSTIP:9080
handoff.ip = $HOSTIP
END

if [[ "$ipv6" = "true" ]]; then
  PROTO_DIST="inet6_tcp"
else
  PROTO_DIST="inet_tcp"
fi

rm /etc/riak/advanced.config
cat<< END > /etc/riak/vm.args
+scl false
+sfwi 500
+P 256000
+e 256000
-env ERL_CRASH_DUMP /var/log/riak/erl_crash.dump
-env ERL_FULLSWEEP_AFTER 0
+Q 262144
+A 64
-setcookie riak
-name $CLUSTER_NAME@$HOST
+K true
+W w
-smp enable
+zdbbl 32768
-proto_dist $PROTO_DIST
END

# Maybe add user config items
if [ -s $USER_CONF ]; then
  cat $USER_CONF >>$RIAK_CONF
fi
