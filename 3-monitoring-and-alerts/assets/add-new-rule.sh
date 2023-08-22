#!/bin/bash

yq -i eval-all 'select(fileIndex == 0) *+ select(fileIndex == 1)' config/alert-definitions.yml new-alert-definition.yaml

