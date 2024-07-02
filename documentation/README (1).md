---
description: What you need to start using OpenHIM Platform.
---

# Getting Started

## Prerequisites

Before getting started with OpenHIM Platform you will need to have Instant OpenHIE tool installed and functional. [Please follow this guide here](https://app.gitbook.com/s/TwrbQZir3ZdvejunAFia/getting-started/quick-start).

{% hint style="info" %}
* If you're a _**Windows**_** user** and are using WSL2 to be able to run the platform: you should limit the amount of RAM/CPU that will be used by WSL, for more details please check the following link: [Limiting memory usage in WSL2](https://www.aleksandrhovhannisyan.com/blog/limiting-memory-usage-in-wsl-2/).
{% endhint %}

## Quick Start

Ensure Docker Swarm in initialised:&#x20;

```bash
docker swarm init
```

Download the latest OpenHIM Platform config file which configures Instant OpenHIE v2 to use OpenHIM Platform packages:

```bash
wget -qO config.yaml https://github.com/jembi/platform/releases/latest/download/config.yaml
```

Download the latest environment variable file, which sets configuration options for OpenHIM Platform packages:

```bash
wget -qO .env.local https://github.com/jembi/platform/releases/latest/download/.env.local
```

Launch some OpenHIM Platform packages, e.g.&#x20;

```bash
instant package init --name interoperability-layer-openhim --name message-bus-kafka --env-file .env.local --dev
```

This launches the OpenHIM and Kafka packages in dev mode (which exposes service ports for development purposes) using the config supplied in the env var file.

To destroy the setup packages and delete their data run:&#x20;

```bash
instant package destroy --name interoperability-layer-openhim --name message-bus-kafka --env-file .env.local --dev
```

Next, you might want to browse the [recipes](recipes/) available in OpenHIM Platform. Each recipe bundles a set of packages and configuration to setup an HIE for a particular purpose.

For example, this command allows the most [comprehensive recipe](recipes/central-data-repository-with-data-warehousing.md) to be deployed with one command:

```bash
wget https://github.com/jembi/platform/releases/latest/download/cdr-dw.env && \
wget https://github.com/jembi/platform/releases/latest/download/config.yaml && \
instant package init -p cdr-dw --dev
```

Alternatively you can also browse the individual set of [packages](packages/) that OpenHIM Platform offers. Each package's documentation lists the environment variables used to configure them.

For more information on how to start stop and destroy packages using the command line, see the [Instant OpenHIE 2 CLI docs](https://jembi.gitbook.io/instant-v2/cli).

Please [join us on Discord](https://discord.gg/R4XwXyZbwk) for support or to chat about new features or ideas.
