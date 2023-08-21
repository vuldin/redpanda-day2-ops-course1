## Verify connectivity to Redpanda

Prometheus is configured to connect to the Redpanda cluster in its configuration file:

```
cat observability/demo/config/prometheus/prometheus.yml
```{{exec}}

In this file, the `scrape_configs` section has a job `redpanda`, and the static config targets list each broker. Prometheus will need to be updated over time as you commission/decommission new brokers.

Open the [Prometheus Console]({{TRAFFIC_HOST1_9090}}/) and start typing `redpanda_` in the expression input field.

![Prometheus connected](./images/prom2.png)

You should see Redpanda metrics in the dropdown list. Now you have verified that Prometheus is pulling metrics from Redpanda. This is an important first step, as all charts and alerts in both Prometheus and Grafana rely on Prometheus to scrape Redpanda metrics.

