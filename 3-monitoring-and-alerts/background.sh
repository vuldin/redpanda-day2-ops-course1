#!/bin/bash

curl -LO https://github.com/redpanda-data/redpanda/releases/latest/download/rpk-linux-amd64.zip
unzip rpk-linux-amd64.zip -d /usr/local/bin/

export ALERT_DEFINITIONS_YAML_FILE_LOCATION=../config/alert-definitions.yml
export GRAFANA_ALERTS_YAML_FILE_LOCATION=../config/grafana/provisioning/alerting/alerts.yml
export PROMETHEUS_ALERTS_YAML_FILE_LOCATION=../config/prometheus/alert-rules.yml

