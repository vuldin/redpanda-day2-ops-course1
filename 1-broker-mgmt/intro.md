![Barbell Panda](./images/reppanda-barbell.png)

# Commissioning Redpanda Brokers

*Here is a [link to our docs](https://docs.redpanda.com/docs/manage/cluster-maintenance/decommission-brokers/) on this topic.*

This scenario focuses on commissioning (adding/removing) brokers.

A popular reason for increasing a cluster's broker count is to expand the cluster's available resources. Conversely, a popular reason for decreasing the broker count is to save money on infrastructure costs over time. But this process should only be taken after considering several factors:

- Availability: do you have enough brokers to span across all racks and/or availability zones?
- Cost: infrastructure costs will be impacted by a change in broker count
- Data retention: storage capacity and possible retention values are determined in large part by the local disk capacity across all brokers
- Durability: you should have more brokers than your lowest partition replication factor
- partition count: this value is determined primarily by the CPU core count of the overall cluster

Right now a Redpanda cluster with 3 brokers is being deployed, along with Redpanda Console. Then a topic will be create with 3 partitions, each with 3 replicas. Finally a simple client (provided by `rpk`) will be started in the background to constantly produce data while you run through this scenario.

Click `Next` once you see that this process has completed (and you see a ready prompt).

