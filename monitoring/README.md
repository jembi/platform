# Prometheus and Grafana

> Note: This is a docker-compose file to support the inclusion of system monitoring in Instant OpenHIE.

Clone the repo and start the docker apps. The `Monitoring` Package is a stand alone package.

To run:

```sh
bash compose.sh init
bash compose.sh up
bash compose.sh down
bash compose.sh destroy
```

* Prometheus Console: <https://{HOST_IP}:9090>
* Grafana Console: <https://{HOST_IP}:3000>
  * **Default username**: admin
  * **Default password**: admin
