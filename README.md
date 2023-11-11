# Day 2 Operations with Redpanda

This is the Github repo for the Redpanda day 2 operations masterclass for Kubernetes.

> Note: As this is a broad topic, this event is likely the first in a series... check back for additional content!

First there is the [cluster setup guide](./0-cluster-setup)...

Then there are 3 scenarios focused on the following tasks:

1. [Commissioning brokers](./1-broker-mgmt)
2. [Upgrading your cluster](./2-rolling-upgrade)
3. [Monitoring and Alerts](./3-monitoring-and-alerts)

Scenarios 1 and 2 make use of the Kubernetes cluster (this guide focuses on AKS). Scenario 3 spins up an environment in killercoda.

You will come away from this session knowing how to:

- Spin up an Azure AKS cluster and deploy Redpanda with Console, TLS, SASL, Tiered storage, and external access via LoadBalancer services
- Create additional node pools and migrate Redpanda over to the new node pool
- Use RPK to verify cluster status and health
- Deploy Grafana charts to view Redpanda metrics
- Configure alerting
- Run a script that generates Grafana and Prometheus alerts
- Add and remove brokers
- Update the cluster to a new version of Redpanda

We will answer your questions throughout this interactive session.

