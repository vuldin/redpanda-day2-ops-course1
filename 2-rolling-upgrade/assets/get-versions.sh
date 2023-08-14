#!/bin/bash

curl -s 'https://hub.docker.com/v2/repositories/redpandadata/redpanda/tags/?ordering=last_updated&page=1&page_size=50' | jq -r '.results[].name' | grep -v 64 | grep -v latest | sort

