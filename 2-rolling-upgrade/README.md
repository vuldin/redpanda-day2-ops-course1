# Upgrading Redpanda

Upgrading Redpanda deployed with the helm chart is super easy! This guide talks about what goes on under the covers, as well as some considerations when determining whether or not to upgrade.

> Note: Redpanda recommends to upgrade frequently, as more recent versions have more bug fixes and features.

*Here is a [link to our docs](https://docs.redpanda.com/current/upgrade/k-rolling-upgrade/) on this topic.*

Upgrading Redpanda is done as a rolling upgrade since each broker within a cluster needs to upgraded in a way that allows the cluster to remain healthy throughout the process. In other words, the cluster can continue to accept connections from clients and all health metrics continue to be within expected ranges.

Here are some ways you can prepare for the rolling upgrade:

- learn about how Redpanda is versioned (more details [here](https://docs.redpanda.com/docs/get-started/intro-to-events/#redpanda-platform-versions)
- find your current version
- check for newer versions (a helpful resource is our [Github releases](https://github.com/redpanda-data/redpanda/releases) page)
- review potential incompatibilities
- know how the rolling upgrade may impact your cluster
- Redpanda can behave differently during an upgrade in various ways: several behaviors can be ignored, some are signals to wait before continuing, and a few signals to revert the process

## Prerequisites

Run through the prerequisites and steps for creating a cluster as shown in [scenario 0](../0-cluster-setup/README.md).

## Preparation

First get the current version of each broker in the cluster and verify that brokers are active:

```
rpk redpanda admin brokers list
```

The output shows we are running `v23.2.14`, and that `MEMBERSHIP-STATUS`/`IS-ALIVE` is `active`/`true`:

```
NODE-ID  NUM-CORES  MEMBERSHIP-STATUS  IS-ALIVE  BROKER-VERSION
0        1          active             true      v23.2.14 - b5a8b9a28971da9853fe11510efbce7346fb4434
1        1          active             true      v23.2.14 - b5a8b9a28971da9853fe11510efbce7346fb4434
2        1          active             true      v23.2.14 - b5a8b9a28971da9853fe11510efbce7346fb4434
```

Now you can check if there is a new version of Redpanda. There are multiple ways to do this, and two of the most popular locations to check are:
1. [Redpanda releases](https://github.com/redpanda-data/redpanda/releases) page on Github
2. [Redpanda tags](https://hub.docker.com/r/redpandadata/redpanda/tags) on Docker Hub

For simplicity you can run the following command, which makes use of the Docker Hub API to output the latest Redpanda version:

```
export VERSION=$(curl -s 'https://hub.docker.com/v2/repositories/redpandadata/redpanda/tags/?ordering=last_updated&page=1&page_size=50' | jq -r '.results[].name' | grep -v "a*64" | sed -En "s/v(.*)/\1/p" | sort -V | tail -1)
echo $VERSION
```

## Upgrade Redpanda

So the brokers in the cluster are each running `v23.2.14`, and `v23.2.15` is available. We will upgrade to this version.

> Note for future learners: `v23.2.15` was the latest when this scenario was created, so we'll upgrade to that version in the next steps.

```
helm upgrade redpanda redpanda --repo https://charts.redpanda.com -n redpanda --wait -f values-2-rolling-upgrade.yaml --reuse-values
```

Once the upgrade is complete, run the following `rpk` command again to verify the cluster is upgraded to the correct version:

```
rpk redpanda admin brokers list
```

