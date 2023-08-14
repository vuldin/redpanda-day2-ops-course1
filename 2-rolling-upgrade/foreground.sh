#!/bin/sh

# start cluster and monitoring
docker-compose \
-p 2-rolling-upgrade \
-f compose.redpanda-0.yaml \
-f compose.redpanda-1.yaml \
-f compose.redpanda-2.yaml \
-f compose.prometheus.yaml \
-f compose.grafana.yaml \
up -d
# create topic
rpk topic create log
# generate data
./generate-data.sh &

