#! /usr/bin/env sh

set -e
set -u
set -o pipefail
set -x

PRIMARY_NAMESPACE="default"
SECONDARY_NAMESPACE="replica"

PRIMARY_RELEASE_NAME="riak"
SECONDARY_RELEASE_NAME="riak"

PRIMARY_NODE="$PRIMARY_RELEASE_NAME-0"
SECONDARY_NODE="$SECONDARY_RELEASE_NAME-0"

PRIMARY_SERVICE="$PRIMARY_RELEASE_NAME-headless.$PRIMARY_NAMESPACE.svc.cluster.local"
SECONDARY_SERVICE="$SECONDARY_RELEASE_NAME-headless.$SECONDARY_NAMESPACE.svc.cluster.local"

exec_on_primary()
{
    kubectl exec -i -n "$PRIMARY_NAMESPACE" "$PRIMARY_NODE" -- $@
}

exec_on_secondary()
{
    kubectl exec -i -n "$SECONDARY_NAMESPACE" "$SECONDARY_NODE" -- $@
}

# Setup cluster names
exec_on_primary riak-repl clustername primary
exec_on_secondary riak-repl clustername secondary

# Remove old connections
exec_on_primary riak-repl disconnect secondary || true

# Establish connections
exec_on_primary riak-repl connect "$SECONDARY_SERVICE:9080"

# Start replication
exec_on_primary riak-repl realtime enable secondary
exec_on_primary riak-repl realtime start secondary