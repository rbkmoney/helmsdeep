#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/questionary-aggr-proxy/questionary-aggr-proxy.jar \
    --logging.config=/opt/questionary-aggr-proxy/logback.xml \
    --logging.level.com.rbkmoney.woody.api.proxy.MethodCallInterceptors=DEBUG \
    --logging.level.com.rbkmoney.woody.thrift.impl.http.interceptor.ext.TransportExtensionBundles=DEBUG \
