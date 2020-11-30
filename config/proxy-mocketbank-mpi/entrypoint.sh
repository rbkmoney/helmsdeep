#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/proxy-mocketbank-mpi/proxy-mocketbank-mpi.jar \
    --server.secondary.ports=8080 \
    --server.port=8022 \
    ${@}
