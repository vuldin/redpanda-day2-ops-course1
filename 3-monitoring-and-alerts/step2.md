## Alert definition file

The `alert-definitions` file is used to define alerts for either Prometheus or Grafana. The following command shows a portion of this file:

```
head -20 config/alert-definitions.yml
```{{exec}}

Once you have found the Redpanda metrics for the alert you want, you can modify this file with a new alert definition and then run the following python script:

```
head -20 alert-generation/generate.py
```{{exec}}

This script generates alert config files for Prometheus and/or Grafana (by default it generates both). More details on how to run this script are [here](https://github.com/redpanda-data/observability/blob/main/alert-generation/README.md). We'll run this script to generate a new alert definition once we progress further through this scenario.

> Note: Production deployments would likely use alerting from only one of these tools, but we are generating alerts in this environment for both tools.

## View alerts in Prometheus

The [Prometheus alerts]({{TRAFFIC_HOST1_9090}}/alerts) page shows the status and details for each alert. If you wanted to modify these alerts, you would edit the `alert-rules` file and then restart Prometheus. This file is located here:

```
head -20 config/prometheus/alert-rules.yml
```{{exec}}

Remember that the alert-generation script mentioned above can generate this file for you! We will leave these alerts at their default values for now.

## View alerts in Grafana

The [Grafana alerts]({{TRAFFIC_HOST1_3000}}/alerting/list) page shows alerts defined in the Grafana config:

![grafana alerts 1](./images/grafana-alerts-1.png)

But if you have configured Prometheus alerts they will also show up here:

![grafana alerts 2](./images/grafana-alerts-2.png)

> Note: You can only silence Grafana alerts here (not the alerts for Prometheus). Silencing alerts ensures no notifications will be sent out for any matching alerts. This does not mean the alerts won't continue to fire in Grafana!

## Send test email

When an alert fires, a notification can be sent to various contact points. This environment has a default email contact point configured [here]({{TRAFFIC_HOST1_3000}}/alerting/notifications):

![grafana alerts 3](./images/grafana-alerts-3.png)

Click the edit action button, then click the "Test" button, and then click "Send test notification". This will fire off an email to that you can read in your [inbox]({{TRAFFIC_HOST1_8025}}/):

![mailhog 1](./images/mailhog-1.png)

## Explore metrics

Grafana is already populated with several good charts for monitoring Redpanda. It's likely that the metrics you care about are already being used on one of these dashboards to provide an interesting visualization.

More details on these charts are available [here](https://github.com/redpanda-data/observability) and [here](https://docs.redpanda.com/docs/manage/monitoring/#use-redpanda-monitoring-examples).

But what if you want to create a visualization for yourself? Let's create a new chart that tracks a useful metric: disk used.

