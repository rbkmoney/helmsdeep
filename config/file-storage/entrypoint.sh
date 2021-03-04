#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar \
    /opt/file-storage/file-storage.jar \
    --logging.config=/opt/file-storage/logback.xml \
    --spring.servlet.multipart.max-file-size=10MB \
    --spring.servlet.multipart.max-request-size=10MB \
    --storage.endpoint=ceph:80 \
    --storage.bucketName=test \
    --storage.accessKey=test \
    --storage.secretKey=test \
    --storage.signingRegion=RU \
    --storage.clientProtocol=HTTP \
    --storage.clientMaxErrorRetry=10 \
    ${@} \
    --spring.config.additional-location=/vault/secrets/application.properties \
