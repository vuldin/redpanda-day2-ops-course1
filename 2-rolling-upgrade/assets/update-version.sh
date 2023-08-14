#!/bin/bash

BROKER=$1
VERSION=$2
if [ -z $BROKER ]
  then
    echo "No broker given"
    exit 1
fi
if [ -z $VERSION ]
  then
    echo "No version given"
    exit 1
fi
PORT=0
if [ $BROKER = "redpanda-0" ]
then PORT=9644
elif [ $BROKER = "redpanda-1" ]
then PORT=9744
elif [ $BROKER = "redpanda-2" ]
then PORT=9844
fi
if [ $PORT -eq 0 ]
then
  echo "$BROKER is invalid"
  exit 1
fi

version="docker.vectorized.io/vectorized/redpanda:$VERSION" yq -i '(.services.*.image = strenv(version))' compose.$BROKER.yaml

