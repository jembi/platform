---
description: What you need to start using Platform.
---

# Getting Started

## Software Requirements

The following tools are needed to run/deploy the stack:

* [Git CLI](https://git-scm.com/book/en/v2/Getting-Started-The-Command-Line)
* [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install) (for windows users)&#x20;
* [Docker](https://docs.docker.com/engine/install/)

You will need first to clone the project on your machine.

{% hint style="info" %}
* If you're a _**Windows**_** user,** you should limit the amount of RAM/CPU that will be used by WSL, for more details please check the following link: [Limiting memory usage in WSL2](https://www.aleksandrhovhannisyan.com/blog/limiting-memory-usage-in-wsl-2/).
* You should run the following command to initialize docker swarm on your machine: `docker swarm init.`
{% endhint %}

## Tech Prerequisites

* [Docker-Swarm](https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/) (example of a version used: v20.10.18)
* [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (for remote deploys only, example of a version used: v1.2.9)
* [Ansible](https://docs.ansible.com/ansible/latest/installation\_guide/intro\_installation.html) (for remote deploys only, example of a version used: v2.9.6)

## Quick Start for Devs

1. From the project root directory, run the `get-cli.sh [linux|windows|macos]` script to download the [platform-cli](https://app.gitbook.com/o/lTiMw1wKTVQEjepxV4ou/s/TwrbQZir3ZdvejunAFia/) executable.
2. Create the logging directory using `sudo mkdir -p /tmp/logs/`.
3. Run the `build-image.sh` script to build the Jembi Platform docker image
4. Run the project using the [platform-cli executable](https://app.gitbook.com/o/lTiMw1wKTVQEjepxV4ou/s/TwrbQZir3ZdvejunAFia/). Refer to the [platform-cli docs](https://app.gitbook.com/o/lTiMw1wKTVQEjepxV4ou/s/TwrbQZir3ZdvejunAFia/) on usage tips.
