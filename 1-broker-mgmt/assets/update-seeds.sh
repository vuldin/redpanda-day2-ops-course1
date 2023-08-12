#!/bin/bash

yq '. *= load("redpanda-config/redpanda-0/updated-seeds.yaml")' redpanda-config/redpanda-0/redpanda.yaml > redpanda.yaml
mv redpanda.yaml redpanda-config/redpanda-0/

