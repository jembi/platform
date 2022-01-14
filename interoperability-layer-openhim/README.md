
# Instant OpenHIE interoperability Component - docker-compose

The Instant OpenHIE interoperability Component is the base of the Instant OpenHIE architecture.

This component consists of two services:

* Interoperability Layer - [OpenHIM](http://openhim.org/)
* FHIR Server - [HAPI FHIR](https://hapifhir.io/)

## Getting Started

> **The below instructions are only to be used for starting up the interoperability services manually for local testing outside of the usual Instant OpenHIE start instructions.**

Proceed with care. This very manual deployment can get complicated.
For the regular start up, please see the [README.md](../../README.md).

### Prerequisites

Ensure that docker is installed. For details on how to install docker click [here](https://linuxize.com/post/how-to-install-and-use-docker-compose-on-ubuntu-18-04/).
For installing docker click [here](https://linuxize.com/post/how-to-install-and-use-docker-on-ubuntu-18-04/).

For our compose scripts to work, one needs to be able to run docker commands without the `sudo` preface. You can configure your system to run without needing the `sudo` preface by running the following command

```bash
./configure-docker.sh
```

#### Create the Instant OpenHIE Volume

Before creating the IL Component services, we need to create a volume containing data used by the IL docker containers.

> This step is only necessary as we are setting up the core **very manually** instead of using the [Instant OpenHIE docker image](https://hub.docker.com/r/openhie/instant).

Start in the root directory of Instant OpenHIE (`/instant`), then execute the below commands to create and populate the volume with data.

```bash
# Volumes can't be accessed directly therefore a "helper" container is attached to facilitate data transfer
docker create --name=instant-openhie-helper -v instant:/instant busybox

# The contents of the instant directory are copied into the volume via the helper container
docker cp . instant-openhie-helper:/instant

# The helper container can be deleted as the data is now persisted in the volume
docker rm instant-openhie-helper
```

Once the volume is created you can continue with the rest of the start up scripts.

### Start Up Interoperability Services

From the instant root directory, run the following command to start up the service.

```bash
./interoperabilty-layer-openhim/swarm.sh init
```

To take down the core run:

```bash
./interoperabilty-layer-openhim/swarm.sh destroy
```

To shut down the services run:

```bash
./interoperabilty-layer-openhim/swarm.sh down
```

To start the services when they have been stopped run:

```bash
./interoperabilty-layer-openhim/swarm.sh up
```

To run in dev mode in which the ports are exposed pass the flag `--dev` as done below

```bash
./interoperabilty-layer-openhim/swarm.sh init --dev
```

To mount the console config for easy development, run the command below

```bash
./interoperabilty-layer-openhim/bindConfig.sh
```

## Accessing the services

### OpenHIM

* Console: <http://localhost:9000>
* Username: **root@openhim.org**
* Password: **instant101**

## Testing the Interoperability Component

As part of the Interoperability Component setup we also do some initial config import for connecting the services together.

* OpenHIM: Import a channel configuration that routes requests to the HAPI FHIR service

For testing this Component we will be making use of `curl` for sending our request, but any client could be used to achieve the same result.

Execute the below `curl` request to successfully route a request through the OpenHIM to query the HAPI FHIR server.

```bash
curl http://localhost:5001/fhir/Patient -H 'Authorization: Custom test'
```
