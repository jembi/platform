
# Instant OpenHIE FHIR Data Store Component - docker-swarm

This component consists of the service:

* Hapi Fhir Server- [HAPI FHIR](https://hapifhir.io/)

## Getting Started

> **The below instructions are only to be used for starting up the FHIR Data Store services manually for local testing outside of the usual Instant OpenHIE start instructions.**

Proceed with care. This very manual deployment can get complicated.
For the regular start up, please see the [README.md](../../README.md).

### Prerequisites

Ensure that docker is installed. For details on how to install docker click [here](https://linuxize.com/post/how-to-install-and-use-docker-compose-on-ubuntu-18-04/).
For installing docker click [here](https://linuxize.com/post/how-to-install-and-use-docker-on-ubuntu-18-04/).

For our compose scripts to work, one needs to be able to run docker commands without the `sudo` preface. You can configure your system to run without needing the `sudo` preface by running the following command

```bash
./configure-docker.sh
```

### Start Up Hapi Fhir Services

From the instant root directory, run the following command to start up the fhir data store.

```bash
./fhir-datastore-hapi-fhir/swarm.sh init
```

To take down the service run:

```bash
./fhir-datastore-hapi-fhir/swarm.sh destroy
```

To shut down the services run:

```bash
./fhir-datastore-hapi-fhir/swarm.sh down
```

To start the services when they have been stopped run:

```bash
./fhir-datastore-hapi-fhir/swarm.sh up
```

To run in dev mode in which the ports are exposed pass the flag `--dev` as done below

```bash
./fhir-datastore-hapi-fhir/swarm.sh init --dev
```

## Accessing the services

### HAPI FHIR

This service is accessible for testing.

<http://{BROAD_CAST_IP}:3447>

In a publicly accessible deployment this port should not be exposed. The OpenHIM should be used to access HAPI-FHIR.

## Testing the Hapi Fhir Component

For testing this Component we will be making use of `curl` for sending our request, but any client could be used to achieve the same result.

Execute the command below

```bash
curl http://{BROAD_CAST_IP}:3447/fhir/Patient
```

> Note: after performing the data recovery, it is possible to get an error from hapi-fhir (500 internal server error) while the data is still being replicated across the cluster. Wait a minute and try again.
