![Redpanda playbook](./images/redpanda-playbook.png)

# Monitoring and Alerting

*Here is a [link to our docs](https://docs.redpanda.com/docs/manage/monitoring/) on this topic.*

We have worked hard to make Redpanda be simple to use. But Redpanda is not perfectly tuned for every use case out of the box, and monitoring the health of your system over time is an important focus for any serious deployment. This enables the ability to configure Redpanda to be best suited for your use case.

This scenario focuses on monitoring a Redpanda deployment with Prometheus and Grafana. It also shows how alerting can be configured once in order to generate proper configuration for both Prometheus and Grafana. Having the ability to generate either Prometheus or Grafana configuration from a single alerts definition source makes it possible for you to choose the best tool for your organization.

Right now the following resources are being deployed:
- Redpanda
- Prometheus and Alert Manager
- Grafana
- An email server (Mailhog)
- Kafka Connect
- Owl Shop, an e-commerce simulation

Click `Start` once you see that this process has completed (and you see a ready prompt).

