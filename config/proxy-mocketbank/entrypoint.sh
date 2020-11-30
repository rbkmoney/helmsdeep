#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/proxy-mocketbank/proxy-mocketbank.jar \
    --server.secondary.ports=8080 \
    --server.port=8022 \
    --cds.client.storage.url=http://cds:8022/v2/storage \
    --hellgate.client.adapter.url=http://hellgate:8022/v1/proxyhost/provider \
    --adapter-mock-mpi.url=http://proxy-mocketbank-mpi:8080 \
    ${@}
