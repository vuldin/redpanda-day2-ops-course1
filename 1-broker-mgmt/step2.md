Decommission the first of the two old brokers, `redpanda-1`:

```
rpk redpanda admin brokers decommission 1
```{{exec}}

Check status of the decommission process (which may already be complete show and empty table):

```
rpk redpanda admin brokers decommission-status 1
```{{exec}}

You can now see that no partitions have their replicas on `redpanda-1`:

```
rpk topic describe -p log
```{{exec}}

The `redpanda-1` container can now be stopped:

```
docker-compose -p 1-commissioning-brokers -f compose.redpanda-1.yaml stop
```{{exec}}

Now repeat the same decommission steps for `redpanda-2`:

Decommission `redpanda-2`:

```
rpk redpanda admin brokers decommission 2
```{{exec}}

Verify `redpanda-2` has completed decommission:

```
rpk redpanda admin brokers decommission-status 2
```{{exec}}

Stop the `redpanda-2` container:

```
docker-compose -p 1-commissioning-brokers -f compose.redpanda-2.yaml stop
```{{exec}}

You can view cluster health and other details with [Redpanda Console]({{TRAFFIC_HOST1_8080}}/).

You now have a cluster with 3 brokers, two of which have been replaced. In a real deployment, you could have been going through this process in order to upgrade the underlying hardware for each broker. If that were the case, then the next steps would be to follow the same process as above, but for `redpanda-0`:

1. add an additional broker `redpanda-5` with seeds `redpanda-3`, `redpanda-4`, and `redpanda-5`
2. update seeds on `redpanda-3` and `redpanda-4` to match `redpanda-5`
3. restart `redpanda-3` and `redpanda-4` one at a time (verifying cluster health after each broker comes back up)
4. decommission `redpanda-0` and then stop the container

