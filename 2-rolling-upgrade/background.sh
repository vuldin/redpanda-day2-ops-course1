#!/bin/bash

# install rpk
curl -LO https://github.com/redpanda-data/redpanda/releases/latest/download/rpk-linux-amd64.zip
unzip rpk-linux-amd64.zip -d /usr/local/bin/
rm rpk-linux-amd64.zip

# config rpk
mv /etc/redpanda/rpk-config.yaml /etc/redpanda/redpanda.yaml

# install yq
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq

# install jq
wget https://github.com/jqlang/jq/releases/download/jq-1.6/jq-linux32 -O /usr/bin/jq && chmod +x /usr/bin/jq

# fix ownership
./delete-data.sh

