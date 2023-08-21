#!/bin/bash

docker-compose - docker-compose.yml -f compose.grafana.yaml up -d
rpk topic create log -p 3
./generate-data.sh &

