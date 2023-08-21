## Verify connectivity to Redpanda

Prometheus is configured to connect to the Redpanda cluster. View the configuration file for this environment:

```
cat observability/demo/config/prometheus/prometheus.yml
```{{exec}}

In this file, the `scrape_configs` section has a job `redpanda`, and the static config targets list each broker. Prometheus will need to be updated over time as you commission/decommission new brokers.

Open the [Prometheus Console]({{TRAFFIC_HOST1_9090}}/) and start typing `redpanda_` in the expression input field.

![Prometheus connected](./images/prom2.png)

You should see Redpanda metrics in the dropdown list.

# Viewing alerts

## Alert definition file



## View Prometheus alerts

The [alerts page]({{TRAFFIC_HOST1_9090}}/alerts) shows the status and details for each alert. If you wanted to modify these alerts, you would edit the [alert-rules file](./config/prometheus/alert-rules.yml) then restart Prometheus. We will leave these alerts at their default values for now.



- [Redpanda Console]({{TRAFFIC_HOST1_8080}}/)
- [Prometheus ]({{TRAFFIC_HOST1_9090}}/)
- [Grafana]({{TRAFFIC_HOST1_3000}}/)
- [MailHog]({{TRAFFIC_HOST1_8025}}/)


Steps in this scenario:
1. view alert rules
2. see alerts in prometheus

http://localhost:9090/alerts

3. see alerts in grafana

http://localhost:3000/alerting/list
  generating both grafana and prometheus alert config, you would only want one
  prom alerts can't be silenced in grafana

4. grafana contact points, send test email

http://localhost:3000/alerting/notifications

5. get test email

http://localhost:8025/#

6. set Grafana alerts to every 30s

http://localhost:3000/alerting/routes
  both `group interval` and `repeat interval` to 30s

7. get email for RPC request latency

http://localhost:8025/#

8. silence alerts from Grafana

http://localhost:3000/alerting/list
  easiest to silence from alert rules page since it auto-populates matching labels
  alert will continue to fire, but notifications won't be sent out while silenced

9. clear emails in mailhog

http://localhost:8025/#

10. see storage increasing in a line chart

open Redpanda default dashboard
expand storage section
duplicate `Disk storage bytes free` chart (`More > Duplicate`)
edit chart
in Panel options, change title to `Raw storage used`
choose to migrate to new chart type
under axis, choose time zone browser time

#in Standard options, change unit to data > bytes(SI)
in Standard options, change unit to Misc > Number


sum(redpanda_storage_disk_total_bytes) - sum(redpanda_storage_disk_free_bytes{instance=~"$node"}) by ($aggr_criteria)
sum(redpanda_storage_disk_total_bytes{instance="redpanda-0.local:9644"}) - sum(redpanda_storage_disk_free_bytes{instance="redpanda-0.local:9644"}) by ($aggr_criteria)

sum(redpanda_storage_disk_total_bytes{instance="redpanda-0:9644"}) - sum(redpanda_storage_disk_free_bytes{instance="redpanda-0:9644"})








1. Configure Redpanda with a smaller segment size

rpk cluster config get compacted_log_segment_size

2. Verify segments are being allocated more frequently
3. Watch local storage increasing

redpanda:
curl -s localhost:9644/public_metrics | grep redpanda_storage_disk_free_bytes

rpk:
rpk cluster logdirs describe --aggregate-into broker --sort-by-size
  x * 1024 * 1024 = 1.8MB after ~15mins

Console:
open cluster overview

Grafana:


3. View firing alerts in Mailhog
4. Silence firing alerts
5. Verify no mail is received from silenced alerts
6. Monitor free disk space in Prometheus
7. Monitor disk usage in Grafana
8. Configure new alert to fire once free storage reaches a specific amount
9. Have alert sent to Mailhog
7. View email in Mailhog


