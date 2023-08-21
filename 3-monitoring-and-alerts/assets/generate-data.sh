#!/bin/bash

while :
do
  BATCH=$(date); printf "$BATCH %s\n" {1..1000000} | rpk topic produce log 2>/dev/null 1>&2
done

