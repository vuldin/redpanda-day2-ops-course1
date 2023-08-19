First get the current version of each broker in the cluster and verify that brokers are active:

```
rpk redpanda admin brokers list
```{{exec}}

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
```{{exec}}

So the brokers in the cluster are each running `v23.2.4`, and `v23.2.5` is available. We will upgrade to this version.

> Note for future learners: `v23.2.5` was the latest when this scenario was created, so we'll upgrade to that version in the next steps.

