U![Juggling Panda](./images/reppanda-juggling.png)

# Upgrading Redpanda

## Prerequisites

The following commands will install dependencies. The final script `delete-data.sh` will set ownership to the redpanda (UID 101) user and also clear the Redpanda data directory (to reset between runs):

```
# install rpk
curl -LO https://github.com/redpanda-data/redpanda/releases/latest/download/rpk-linux-amd64.zip
unzip rpk-linux-amd64.zip -d /usr/local/bin/
rm rpk-linux-amd64.zip

# config rpk
mv /etc/redpanda/rpk-config.yaml /etc/redpanda/redpanda.yaml

# install yq
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq

# install jq
wget https://github.com/jqlang/jq/releases/download/jq-1.6/jq-linux32 -O /usr/bin/jq && chmod +x /usr/bin/jq

# fix ownership
./delete-data.sh
```

## Initial setup

Once prerequisite dependencies are installed, a few commands are needed in order to get your environment into the required state:

```
# start 3 initial brokers
docker-compose \
-p 1-commissioning-brokers \
-f compose.redpanda-0.yaml \
-f compose.redpanda-1.yaml \
-f compose.redpanda-2.yaml \
-f compose.console.yaml \
up -d

# create topic
rpk topic create log -p 3 -r 3

# generate data
./generate-data.sh &
```

## Intro

*Here is a [link to our docs](https://docs.redpanda.com/docs/manage/cluster-maintenance/rolling-upgrade/) on this topic.*

This scenario focuses on upgrading Redpanda. This type of upgrade is known as a rolling upgrade, since each broker within a cluster needs to upgraded in a way that allows the cluster to remain healthy throughout the process. In other words, the cluster can continue to accept connections from clients and all health metrics continue to be within expected ranges.

Here are some ways you can prepare for the rolling upgrade:

- learn about how Redpanda is versioned (more details [here](https://docs.redpanda.com/docs/get-started/intro-to-events/#redpanda-platform-versions)
- find your current version
- check for newer versions (a helpful resource is our [Github releases](https://github.com/redpanda-data/redpanda/releases) page)
- review potential incompatibilities
- know how the rolling upgrade may impact your cluster
- differentiate between various potential cluster affects; several can be ignored, some would mean waiting to continue, and a few mean to revert the process

Right now a 3-broker Redpanda cluster is being deployed, along with Prometheus and Grafana for viewing metrics. Click `Start` once you see that this process has completed (and you see a ready prompt).

## Preparation

First get the current version of each broker in the cluster and verify that brokers are active:

```
rpk redpanda admin brokers list
```

The output shows we are running `v23.2.4`, and that `MEMBERSHIP-STATUS`/`IS-ALIVE` is `active`/`true`:

```
NODE-ID  NUM-CORES  MEMBERSHIP-STATUS  IS-ALIVE  BROKER-VERSION
0        1          active             true      v23.2.4 - e8a873c16bf9c25132859b55bd9ea6acb901a496
1        1          active             true      v23.2.4 - e8a873c16bf9c25132859b55bd9ea6acb901a496
2        1          active             true      v23.2.4 - e8a873c16bf9c25132859b55bd9ea6acb901a496
```

Now you can check if there is a new version of Redpanda. There are multiple ways to do this, and two of the most popular locations to check are:
1. [Redpanda releases](https://github.com/redpanda-data/redpanda/releases) page on Github
2. [Redpanda tags](https://hub.docker.com/r/redpandadata/redpanda/tags) on Docker Hub

For simplicity you can run the following command, which makes use of the Docker Hub API to list available Redpanda versions:

```
./get-versions.sh
```

So the brokers in the cluster are each running `v23.2.4`, and `v23.2.5` is available. We will upgrade to this version.

> Note for future learners: `v23.2.5` was the latest when this scenario was created, so we'll upgrade to that version in the next steps.

## Maintenance mode

Now you know that you want to upgrade to `v23.2.5`. The first step is to put the target broker into maintenance mode.

First verify the cluster is healthy:

```
rpk cluster health
```

A broker should be put into maintenance mode before applying an upgrade. More details on what maintenance mode is, what it is used for, other details are found in [this page](https://docs.redpanda.com/docs/manage/node-management/) in our docs.

We will now put `redpanda-2` into maintenance mode:

```
rpk cluster maintenance enable 2 --wait
```

You can check the maintenance status with the following command:

```
rpk cluster maintenance status
```

The output shows that `DRAINING`/`FINISHED` for broker 2 is `true`/`true`:

```
NODE-ID  DRAINING  FINISHED  ERRORS  PARTITIONS  ELIGIBLE  TRANSFERRING  FAILED
0        false     false     false   0           0         0             0
1        false     false     false   0           0         0             0
2        true      true      false   1           0         0             0
```

> Note: The output above shows a value of `1` in the `PARTITIONS` column for broker 2. Your output may show a different partition count, as this is the number of leader partitions located on this broker.

The cluster will continue to report as healthy, and clients will be able to connect. You can verify cluster health again:

```
rpk cluster health
```

Now check grafana for any issues: [Grafana]({{TRAFFIC_HOST1_3000}}/)

Open the dashboard at `Dashboards > General > Redpanda Ops Dashboard`.

It is normal to see changes in metrics such as:
- increase in leadership transfers
- nominally higher latencies
- nominally higher resource (CPU/memory) usage

These normal behaviors should appear and then gradual return to lower values once the cluster completes with handling the maintenance change on the broker. Rather than focus on these changes above, try to focus on areas like the following:
- high spikes in latency
- high spikes in CPU usage
- leaderless partitions
- under-replicated partitions

Now `redpanda-2` is in maintenance mode, the cluster is healthy, metrics are showing no issues in Grafana, and we are ready to upgrade.

## Upgrading a broker

The upgrade process is different depending on your platform. These steps follow the Docker platform steps. See [our docs](https://docs.redpanda.com/docs/manage/cluster-maintenance/rolling-upgrade/#upgrade-your-version) for steps to take on other platforms.

The steps below provide some convenience scripts to make sure each step is less prone to error and to be more focused on what you are doing by running each command (rather than the Docker environment). Feel free to look at the contents of any script to get more details on exactly what is being done under the covers.

First stop `redpanda-2` broker:

```
./stop-broker.sh redpanda-2
```

Then update `redpanda-2` to version `23.2.5`. The following command runs a convenience script that edits the Docker compose file responsible for `repanda-2` to make use of `v23.2.5`:

```
./update-version.sh redpanda-2 v23.2.5
```

Start `redpanda-2` with the updated version:

```
docker-compose -p 2-rolling-upgrade -f compose.redpanda-2.yaml up -d
```

Check metrics following [these guidelines](https://docs.redpanda.com/docs/manage/cluster-maintenance/rolling-upgrade/#check-metrics), in [Grafana]({{TRAFFIC_HOST1_3000}}/)

Open the dashboard at `Dashboards > General > Redpanda Ops Dashboard`.

Verify that `redpanda-2` is now at `v23.2.5`:

```
rpk redpanda admin brokers list
```

Bring `redpanda-2` out of maintenance mode:

```
rpk cluster maintenance disable 2
```

Verify no brokers are in maintenance mode:

```
rpk cluster maintenance status
```

Verify cluster health:

```
rpk cluster health
```

Click `Next` to continue to with the final steps.

## Completing cluster upgrade

We can now continue upgrading the remaining brokers (`redpanda-0`, and `redpanda-1`), and we'll continue in reverse order with `redpanda1`.

> Note: While the commands below are provided, the details of what each command does is not included.  Instead you can find these details on the previous section where we walked through all same commands for `redpanda-2`. Copy and paste each command into the terminal to the left and run them separately.

Here are the commands to follow in order for `redpanda-1`:

```
rpk cluster health
rpk cluster maintenance enable 1 --wait
rpk cluster maintenance status
rpk cluster health
./stop-broker.sh redpanda-1
./update-version.sh redpanda-1 v23.2.5
docker-compose -p 2-rolling-upgrade -f compose.redpanda-1.yaml up -d
rpk redpanda admin brokers list
rpk cluster maintenance disable 1
rpk cluster maintenance status
```

And here are the commands for `redpanda-0`:

```
rpk cluster health
rpk cluster maintenance enable 0 --wait
rpk cluster maintenance status
rpk cluster health
./stop-broker.sh redpanda-0
./update-version.sh redpanda-0 v23.2.5
docker-compose -p 2-rolling-upgrade -f compose.redpanda-0.yaml up -d
rpk redpanda admin brokers list
rpk cluster maintenance disable 0
rpk cluster maintenance status
```

Finally, you can verify that all brokers are upgraded to `v23.2.5`:

```
rpk redpanda admin brokers list
```

