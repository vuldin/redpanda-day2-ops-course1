![Decommission redpanda-1](./images/decommissioning-1.png)

Decommission the first of the two old brokers, `redpanda-1`:

```
rpk redpanda admin brokers decommission 1
```{{exec}}

Check status of the decommission process (which may already be complete show and empty table):

```
rpk redpanda admin brokers decommission-status 1
```{{exec}}

The output will eventually include the following:

```
Node 1 is decommissioned successfully.
```

You can now see that no partitions have their replicas on `redpanda-1`:

```
rpk topic describe -p log
```{{exec}}

```
PARTITION  LEADER  EPOCH  REPLICAS  LOG-START-OFFSET  HIGH-WATERMARK
0          4       3      [0 3 4]   0                 56030
1          2       2      [0 2 3]   0                 54760
2          2       2      [2 3 4]   0                 54810
```

The `redpanda-1` container can now be stopped:

```
docker-compose -p 1-commissioning-brokers -f compose.redpanda-1.yaml stop
```{{exec}}

Now repeat the same decommission steps for `redpanda-2`:
![Decommission redpanda-2](./images/decommissioning-2.png)

Decommission `redpanda-2`:

```
rpk redpanda admin brokers decommission 2
```{{exec}}

Verify `redpanda-2` has completed decommission:

```
rpk redpanda admin brokers decommission-status 2
```{{exec}}

The output will eventually include the following:

```
Node 2 is decommissioned successfully.
```

Stop the `redpanda-2` container:

```
docker-compose -p 1-commissioning-brokers -f compose.redpanda-2.yaml stop
```{{exec}}

You can view cluster health and other details with [Redpanda Console]({{TRAFFIC_HOST1_8080}}/).

See broker status under cluster overview:
![Console broker status](./images/console-overview.png)

See location of partition replicas under _Topics>log>partitions_:
![Console partition replicas](./images/console-replicas.png)

