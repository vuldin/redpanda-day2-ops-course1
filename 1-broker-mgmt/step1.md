You will be replacing the cluster's brokers in a way that keeps the cluster available for clients. A likely reason for this could be that you need to replace/upgrade the underlying physical/virtual hardware.

You can find your cluster's highest partition replica count using `rpk`:

```
rpk topic ls | awk '{print $3}' | grep -v REPLICAS | sort | tail -1
```{{exec}}

Since our cluster has partitions with 3 replicas, we must first add additional brokers to the cluster before removing the older brokers. We will add 2 new brokers at the same time to go to a 5-broker cluster, but you could choose to only add one broker at a time.

> Note: It is safe to **add** multiple brokers to a cluster without waiting because new brokers hold no partition data. But since existing brokers do hold data, you should only **remove** a single broker at a time.

Add the two additional brokers to the cluster:

```
docker-compose -p 1-commissioning-brokers -f compose.redpanda-3.yaml -f compose.redpanda-4.yaml up -d
```{{exec}}

Verify the cluster is now a healthy 5-broker cluster:

```
rpk cluster health
```{{exec}}

A cluster has seed servers to help it startup and join brokers correctly to the running cluster. You want to ensure that each broker in the cluster has the same seed server list, and that the list contains at least three entries (the more the better). You also want to make sure there is at least one seed server available at all times. More details [here](https://docs.redpanda.com/docs/deploy/deployment-option/self-hosted/manual/production/production-deployment/#configure-the-seed-servers).

The 2 additional brokers were added to the broker with an updated seed server list that contained themselves plus `redpanda-0`. We will now apply this same update to the Redpanda configuration for `redpanda-0`:

```
./update-seeds.sh
```{{exec}}

`redpanda-0` must be restarted for this change to take affect:

```
docker-compose -p 1-commissioning-brokers -f compose.redpanda-0.yaml restart
```{{exec}}

Now `redpanda-0`, `redpanda-3`, and `redpanda-4` share an identical seed server list that excludes the other two brokers. These are the two brokers that will be removed next.

