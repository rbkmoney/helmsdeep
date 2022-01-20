#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/proxy-mocket-inspector/proxy-mocket-inspector.jar \
    --logging.config=/opt/proxy-mocket-inspector/logback.xml \
    --server.port=8022 \
    ${@}
