#!/bin/sh
set -ue

function onExit {
    pg_ctl -D /var/lib/postgresql/9.6/data stop -w
}
trap onExit EXIT

pg_ctl -D /var/lib/postgresql/9.6/data start -w
java \
    "-XX:OnOutOfMemoryError=kill %p" -XX:+HeapDumpOnOutOfMemoryError \
    -jar /opt/binbase/binbase.jar \
    ${@}
