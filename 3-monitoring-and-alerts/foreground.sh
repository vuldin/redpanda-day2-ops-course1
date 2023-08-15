#!/bin/bash

git clone https://github.com/redpanda-data/observability.git
cd observability/demo
docker-compose pull
docker-compose up -d

