#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/questionary-aggr-proxy/questionary-aggr-proxy.jar \
    --logging.config=/opt/questionary-aggr-proxy/logback.xml \
    --management.security.flag=false \
    --management.metrics.export.statsd.enabled=false \
    --management.endpoint.health.show-details=always \
    --management.endpoint.metrics.enabled=true \
    --management.endpoint.prometheus.enabled=true \
    --management.endpoints.web.exposure.include=health,info,prometheus \
    --logging.level.com.rbkmoney.woody.api.proxy.MethodCallInterceptors=DEBUG \
    --logging.level.com.rbkmoney.woody.thrift.impl.http.interceptor.ext.TransportExtensionBundles=DEBUG \
