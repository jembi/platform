---
description: A package for monitoring the platform services
---

# Monitoring

The monitoring package sets up services to monitor the entire deployed stack. This includes the state of the servers involved in the docker swarm, the docker containers themselves and particular applications such as Kafka.

This monitoring package uses:&#x20;

* Grafana: for dashboards
* Prometheus: for recording metrics
* Cadvisor: for reading docker container metrics&#x20;
* Kafka: for saving a backup of metrics data

To use the monitoring services, include the `monitoring` package id to your list of package ids when standing up the platform.

## Adding application specific metrics

The monitoring service utilises service discovery to discover new metric endpoints to scrape.

To use custom metrics for an application, first configure that application to provide a [Prometheus compatible metrics endpoint](https://prometheus.io/docs/instrumenting/exporters/). Then, let the monitoring service know about it by configuring specific docker service labels that tell the monitoring service to add a new endpoint to scrape. E.g. see lines 8-9:

<pre class="language-yaml" data-line-numbers><code class="lang-yaml">  kafka-minion:
    image: quay.io/cloudhut/kminion:master
    hostname: kafka-minion
    environment:
      KAFKA_BROKERS: kafka:9092
    deploy:
      labels:
<strong>        - prometheus-job-service=kafka
</strong><strong>        - prometheus-address=kafka-minion:8080</strong></code></pre>

`prometheus-job` lets Prometheus know to enable monitoring for this container and `prometheus-address` give the endpoint that the monitoring can access the metrics on. By default this is assumed to be at the path `/metrics` by Prometheus.

## Adding additional dashboards

To add additional dashboards simply use docker configs to add new Grafana dashboard json files into this directory in the Grafana container: `/etc/grafana/provisioning/dashboards/`

That directory will be scanned periodically and new dashboards will automatically be added to Grafana.

Grafana dashboard json file may be exported directly from the Grafana when saving dashboards or you may lookup the many existing dashboard in the [Grafana marketplace](https://grafana.com/grafana/dashboards).
