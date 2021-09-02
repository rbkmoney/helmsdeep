#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/xrates/xrates.jar \
    --logging.config=/opt/xrates/logback.xml \
    --management.security.enabled=false \
    --management.security.flag=false \
    --management.metrics.export.statsd.flavor=etsy \
    --management.metrics.export.statsd.enabled=true \
    --management.metrics.export.prometheus.enabled=true \
    --management.endpoint.health.show-details=always \
    --management.endpoint.metrics.enabled=true \
    --management.endpoint.prometheus.enabled=true \
    --management.endpoints.web.exposure.include=health,info,prometheus \
    --spring.application.name=xrates \
    --service.mg.automaton.url=http://machinegun:8022/v1/automaton \
    --service.mg.automaton.namespace=xrates \
    --service.mg.eventSink.url=http://machinegun:8022/v1/event_sink
    --service.mg.eventSink.sinkId=xrates \
    --sources.needInitialize=true \
    ${@} \
    --spring.config.additional-location=/vault/secrets/application.properties \
    --sources.provider.secrets.file.path=/vault/secrets/xrates/sources.file \
