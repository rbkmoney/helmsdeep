#!/bin/sh
set -ue

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    ${@} \
    --spring.config.additional-location=/vault/secrets/application.properties
