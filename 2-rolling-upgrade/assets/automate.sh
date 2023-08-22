#!/bin/bash

#TODO turn this into Ansible?

echo -n  "Checking cluster health"
for i in {1..5}; do echo  -n ".."; sleep 0.5; done

echo ""
if [[ $(rpk cluster health |  grep 'down' |grep -oP '(?<=\[).*(?=])' | wc -c) -ne 0 ]]; then
    echo "Cluster not healthy, cannot upgrade until resolved, run rpk cluster health for more info.. "
    exit;
fi

echo -n "Enabling maintenance for node "
for i in {1..5}; do echo  -n ".."; sleep 0.5; done
echo ""
rpk cluster maintenance enable 0

echo ""
echo -n "Check if maintenance successful "
while ! rpk cluster maintenance status | awk 'NR==2{ print; }' | awk '{print $2 $3 $4}'| grep truetruefalse; do
  echo  -n ".."
  sleep 1;
done

echo ""
echo -n  "Checking cluster health "
for i in {1..5}; do echo  -n ".."; sleep 0.5; done

if [[ $(rpk cluster health |  grep 'down' |grep -oP '(?<=\[).*(?=])' | wc -c) -ne 0 ]]; then
    echo "Cluster not healthy, cannot upgrade until resolved, run rpk cluster health for more info.. "
    exit;
fi

echo ""
echo -n "Stopping Redpanda "
for i in {1..5}; do echo  -n ".."; sleep 0.5; done
echo ""
bash stop-broker.sh redpanda-0

echo ""
echo -n "Updating Redpanda version "
for i in {1..5}; do echo  -n ".."; sleep 0.5; done
echo ""
bash update-version.sh redpanda-0 v23.2.5

echo ""
echo -n "Restarting Redpanda "
for i in {1..2}; do echo  -n ".."; sleep 0.5; done
echo ""
docker-compose -p 2-rolling-upgrade -f compose.redpanda-0.yaml up -d

echo ""
echo -n "Check cluster status.."
while ! docker container inspect -f '{{.State.Running}}' redpanda-0.local; do
  echo  -n ".."
  sleep 1;
done

echo ""
echo -n "Bringing node back online"
for i in {1..2}; do echo  -n ".."; sleep 0.5; done
echo ""
rpk cluster maintenance disable 0


echo -n "Check online status.."
while ! rpk cluster maintenance status | awk 'NR==2{ print; }' | awk '{print $2 $3 $4}'| grep falsefalsefalse; do
  echo  -n ".."
  sleep 1;
done

echo ""
echo "Current cluster version:"
for i in {1..2}; do echo  -n ".."; sleep 0.5; done
echo ""
rpk redpanda admin brokers list

echo -n "Node upgrade successful"

