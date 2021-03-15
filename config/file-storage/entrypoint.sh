#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/file-storage/file-storage.jar \
    --logging.config=/opt/file-storage/logback.xml \
    --management.security.flag=false \
    --management.metrics.export.statsd.flavor=etsy \
    --management.metrics.export.statsd.enabled=true \
    --management.metrics.export.prometheus.enabled=true \
    --management.endpoint.health.show-details=always \
    --management.endpoint.metrics.enabled=true \
    --management.endpoint.prometheus.enabled=true \
    --management.endpoints.web.exposure.include=health,info,prometheus \
    --spring.servlet.multipart.max-file-size=10MB \
    --spring.servlet.multipart.max-request-size=10MB \
    --storage.endpoint=minio:9000 \
    --storage.bucketName=files \
    --storage.signingRegion=RU \
    --storage.clientProtocol=HTTP \
    --storage.clientMaxErrorRetry=10 \
    ${@} \
    --spring.config.additional-location=/vault/secrets/application.properties \
