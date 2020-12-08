#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/proxy-mocketbank-mpi/proxy-mocketbank-mpi.jar \
    --server.port=8080 \
    ${@}
