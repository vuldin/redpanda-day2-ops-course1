#!/bin/bash

docker-compose -f docker-compose.yml -f compose.grafana.yaml up -d
rpk topic create log -p 3
#./generate-data.sh &

export ALERT_DEFINITIONS_YAML_FILE_LOCATION=../config/alert-definitions.yml
export GRAFANA_ALERTS_YAML_FILE_LOCATION=../config/grafana/provisioning/alerting/alerts.yml
export PROMETHEUS_ALERTS_YAML_FILE_LOCATION=../config/prometheus/alert-rules.yml
