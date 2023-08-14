Upgrade process is different depending on your platform. These steps follow the Docker platform steps. See [our docs](https://docs.redpanda.com/docs/manage/cluster-maintenance/rolling-upgrade/#upgrade-your-version) for steps to take on other platforms.

The steps below provide some convenience scripts to make sure each step is less prone to error and to be more focused on what you are doing by running each command (rather than the Docker environment). Feel free to look at the contents of any script to get more details on exactly what is being done under the covers.

Stop `redpanda-2` broker:

```
./stop-broker.sh redpanda-2
```{{exec}}

Update `redpanda-2` to version `23.2.5`. The following script edits the Docker compose file responsible for `repanda-2` to make use of Redpanda `v23.2.5`:

```
./update-version.sh redpanda-2 v23.2.5
```{{exec}}

Start the broker with the updated version

```
docker-compose -p 2-rolling-upgrade -f compose.redpanda-2.yaml up -d
```{{exec}}

Check metrics following [these guidelines](https://docs.redpanda.com/docs/manage/cluster-maintenance/rolling-upgrade/#check-metrics), in [Grafana]({{TRAFFIC_HOST1_3000}}/)

Dashboards > General > Redpanda Ops Dashboard

Verify that `redpanda-2` is now at `v23.2.5`:

```
rpk redpanda admin brokers list
```{{exec}}

Bring `redpanda-2` out of maintenance mode:

```
rpk cluster maintenance disable 2
```{{exec}}

Verify no brokers are in maintenance mode:

```
rpk cluster maintenance status
```{{exec}}

Verify cluster health:

```
rpk cluster health
```{{exec}}

Repeat the same steps for `redpanda-1` and `redpanda-2`:

