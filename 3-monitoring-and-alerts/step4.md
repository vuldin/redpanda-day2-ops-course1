## Create a new alert

Now that you have a new Storage dashboard with two custom charts, let's create a new alert for the same metric.

A new alert definition has been created for you here:

```
cat new-alert-definition.yaml
```{{exec}}

This format is what our alert generation script handles, and is very similar to what Prometheus requires. But this definition also contains some additional details that will be used to generate a Grafana alert. Here are some definitions of some key parameters:

- **expr**: the expression that will determine the value for this alert
- **threshold**: the value that, when reached, will trigger the alert
- **comparison**: determines how to compare the value to the threshold
- **for**: duration for which the evaluation must be true before triggering this alert

> Note: The threshold is set to `10000000000` to ensure this alert will fire in this environment. If you want to use a similar alert in some other environment, you will want to modify this value based on the total disk used along with how much total disk capacity you have available.

Earlier we showed that we already have an alert definition file that was used to create the alert rules we previously saw in Grafana. The new definition shown above can be added to that existing file with the following command:

```
./add-new-rule.sh
```{{exec}}

The new rule is now merged into the original definition file:

```
tail -20 config/alert-definitions.yml
```{{exec}}

Now we can use the alert generation script to create new Prometheus and Grafana alert configurations:

```
cd alert-generation
python3 generate.py
cd ..
```{{exec}}

Restart Grafana in order to pick up this change:

```
docker-compose -f compose.grafana.yaml restart
```{{exec}}

Open the [Grafana alerts]({{TRAFFIC_HOST1_3000}}/alerting/list) page to see that the new alert in the "Redpanda Critical" section.

The alert should quickly move into "Pending" state and stay there for 1 minute, and then move to "Firing" state. You can then view the email sent from Grafana in your [inbox]({{TRAFFIC_HOST1_8025}}/).

