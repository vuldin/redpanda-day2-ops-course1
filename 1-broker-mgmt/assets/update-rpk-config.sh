#!/bin/bash

kafkaAddress="localhost:9392" yq -i '(.rpk.kafka_api.brokers[0] = strenv(kafkaAddress))' /etc/redpanda/redpanda.yaml
adminAddress="localhost:9944" yq -i '(.rpk.admin_api.addresses[0] = strenv(adminAddress))' /etc/redpanda/redpanda.yaml

