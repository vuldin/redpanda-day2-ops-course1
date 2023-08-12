# Start 2 new brokers

```
docker-compose -p 1-commissioning-brokers -f compose.redpanda-3.yaml -f compose.redpanda-4.yaml up -d
```{{exec}}

# Update seed servers on redpanda-0

```
./update-seeds.sh
```{{exec}}

# restart redpanda-0 to use new seeds

```
docker-compose -p 1-commissioning-brokers -f compose.redpanda-0.yaml restart
```{{exec}}

# decommission 2 old brokers

Decommission the `redpanda-1`:

```
rpk redpanda admin brokers decommission 1
```{{exec}}

Check status of the decommission process (this will likely already be complete and will show and empty table):

```
rpk redpanda admin brokers decommission-status 1
```{{exec}}

Stop the `redpanda-1` container:

```
docker-compose -p 1-commissioning-brokers -f compose.redpanda-1.yaml stop
```{{exec}}

Repeat the same decommission steps for `redpanda-2`:

```
rpk redpanda admin brokers decommission 2
```{{exec}}

```
rpk redpanda admin brokers decommission-status 2
```{{exec}}

```
docker-compose -p 1-commissioning-brokers -f compose.redpanda-2.yaml stop
```{{exec}}

- [Redpanda Console]({{TRAFFIC_HOST1_8080}}/)

