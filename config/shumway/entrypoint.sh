#!/bin/sh
set -ue

source /vault/secrets/db-creds

java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    ${@} \
    --spring.datasource.url=jdbc:postgresql://postgres-postgresql.default:5432/shumway \
    --spring.datasource.username=postgres \
    --spring.datasource.password=uw2dFhY9EP  # TODO: Use credentials from vault
