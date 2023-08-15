![Juggling Panda](./images/reppanda-juggling.png)

# Upgrading Redpanda

*Here is a [link to our docs](https://docs.redpanda.com/docs/manage/cluster-maintenance/rolling-upgrade/) on this topic.*

This scenario focuses on upgrading Redpanda. This type of upgrade is known as a rolling upgrade, since each broker within a cluster needs to upgraded in a way that allows the cluster to remain healthy throughout the process. In other words, the cluster can continue to accept connections from clients and all health metrics continue to be within expected ranges.

Here are some ways you can prepare for the rolling upgrade:

- learn about how Redpanda is versioned (more details [here](https://docs.redpanda.com/docs/get-started/intro-to-events/#redpanda-platform-versions)
- find your current version
- check for newer versions (a helpful resource is our [Github releases](https://github.com/redpanda-data/redpanda/releases) page)
- review potential incompatibilities
- know how the rolling upgrade may impact your cluster
- differentiate between various potential cluster affects; several can be ignored, some would mean waiting to continue, and a few mean to revert the process

Right now a 3-broker Redpanda cluster is being deployed, along with Prometheus and Grafana for viewing metrics. Click next once you see that this process has completed (and you see a ready prompt).

