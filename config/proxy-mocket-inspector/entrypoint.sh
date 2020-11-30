#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/proxy-mocket-inspector/proxy-mocket-inspector.jar \
    --server.port=8022 \
    ${@}
