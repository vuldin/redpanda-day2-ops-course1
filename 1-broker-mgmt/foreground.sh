#!/bin/sh

# start 3 initial brokers
docker-compose \
-p 1-commissioning-brokers \
-f compose.redpanda-0.yaml \
-f compose.redpanda-1.yaml \
-f compose.redpanda-2.yaml \
-f compose.console.yaml \
up -d
# create topic
rpk topic create log -p 3 -r 3
# generate data
./generate-data.sh &

