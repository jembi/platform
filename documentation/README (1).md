---
description: What you need to start using OpenHIM Platform.
---

# Getting Started

## Software Requirements

The following tools are needed to run/deploy platform:

* [Docker](https://docs.docker.com/engine/install/)

{% hint style="info" %}
* If you're a _**Windows**_** user**, you must use WSL2 to be able to run the platform.
* You should limit the amount of RAM/CPU that will be used by WSL, for more details please check the following link: [Limiting memory usage in WSL2](https://www.aleksandrhovhannisyan.com/blog/limiting-memory-usage-in-wsl-2/).
{% endhint %}

## Quick Start

1. Once Docker is installed initialise Docker Swarm: `docker swarm init`
2. Download the [Instant OpenHIE 2 binary](https://jembi.gitbook.io/instant-v2/getting-started). Once you are able to execute the instant executable, return here.
3. Go to the OpenHIM Platform [https://github.com/jembi/platform/releases/latest](https://github.com/jembi/platform/releases/latest) page and use the `<tag_name>` for the following steps.
4. Download the latest OpenHIM Platform config file which configures Instant OpenHIE v2 to use OpenHIM Platform packages: `wget https://raw.githubusercontent.com/jembi/platform/<tag_name>/config.yaml`&#x20;

{% hint style="info" %}
&#x20;e.g. `wget https://raw.githubusercontent.com/jembi/platform/2.5.0/config.yaml`
{% endhint %}

5. Download the latest environment variable file, which sets configuration options for OpenHIM Platform packages: `wget https://raw.githubusercontent.com/jembi/platform/<tag_name>/.env.local`
6. Launch some OpenHIM Platform packages, e.g. `./instant package init --name interoperability-layer-openhim --name message-bus-kafka --env-file .env.local --dev` This launches the OpenHIM and Kafka packages in dev mode (which exposes service ports for development purposes) using the config supplied in the env var file.

Next, you might want to browse the [recipes](recipes/) available in OpenHIM Platform. Each recipe bundles a set of packages and configuration to setup an HIE for a particular purpose.

Alternatively you can also browse the individual set of [packages](packages/) that OpenHIM Platform offers. Each package's documentation lists the environment variables used to configure them.

For more information on how to start stop and destroy packages using the command line, see the [Instant OpenHIE 2 CLI docs](https://jembi.gitbook.io/instant-v2/cli).
