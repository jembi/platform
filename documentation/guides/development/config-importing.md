---
description: This section defines the configuration importing methods used in the Platform
---

# Config Importing

## Overview

Certain packages in the Platform require configuration to enable their intended functionality in a stack. For instance, the OpenHIM package requires the setting of users, channels, roles, and so on. Other packages, such as JS Report or Kibana, require importing of pre-configured dashboards stored in compressed files.

Most services in the Platform can be configured by sending a request containing the required configuration files to the relevant service API. To achieve this, the Platform leverages a helper container to make that API call.&#x20;

{% hint style="info" %}
If a package uses a config importer, its configuration can be found in the relevant package's `importer` section.
{% endhint %}

## The Helper Container

### The Process

As part of the package-launching process, the to-be-configured service is deployed, then awaits configuring. Before the configuration can take place, the relevant service is waited upon for joining to the Docker internal network. Once the service has joined the network, the helper container is launched and makes the API request to configure the service.

### Images

**jembi/api-config-importer**

For reference on how to use the `jembi/api-config-importer` image, see the repo [here](https://github.com/jembi/api-config-importer).

**jembi/instantohie-config-importer**

For reference on how to use the `jembi/instantohie-config-importer` image, see the repo [here](https://github.com/jembi/instantohie-config-importer).
