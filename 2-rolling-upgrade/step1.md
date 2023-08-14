get current version of each broker in the cluster, and verify that brokers are active:

```
rpk redpanda admin brokers list
```{{exec}}

find new version:

```
./get-versions.sh
```{{exec}}

The brokers are currently running `v23.2.4`, and `v23.2.5` is available. We will upgrade to this version.

> Note for future learners: `v23.2.5` was the latest when this scenario was created, so we'll upgrade to that version in the next steps.

Verify cluster health:

```
rpk cluster health
```{{exec}}

### maintenance mode

Put a broker into maintenance mode:

```
rpk cluster maintenance enable 2 --wait
```{{exec}}

Check maintenance status:

```
rpk cluster maintenance status
```{{exec}}

Verify cluster health:

```
rpk cluster health
```{{exec}}

Check grafana for any issues: [Grafana]({{TRAFFIC_HOST1_3000}}/)

Dashboards > General > Redpanda Ops Dashboard

Grafana will not report the broker as down when in maintenance mode. Instead you will be looking for cluster health issues such as:
- spikes in latency
- spikes in CPU usage
- leaderless partitions
- under-replicated partitions

It is normal to see things such as:
- increase in leadership transfers
- nominally higher latencies
- nominally higher resource (CPU/memory) usage

These normal behaviors should appear and then gradual return to lower values once the cluster completes with handling the maintenance change on the broker.

Now we are ready to upgrade `redpanda-2`.

