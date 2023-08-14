#!/bin/bash

BROKER=$1
if [ -z $BROKER ]
  then
    echo "No broker given"
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

CONTAINER_ID=$(docker ps --format "{{.ID}} {{.Ports}}" | grep $PORT | awk '{print $1}')
docker stop $CONTAINER_ID
docker rm $CONTAINER_ID

