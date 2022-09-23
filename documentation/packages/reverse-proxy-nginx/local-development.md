---
description: Reverse proxy for secure and insecure nginx configurations.
---

# Local Development

## Nginx Reverse Proxy

This package can be used to secure all of the data transfered to and from services using SSL encryption and also to generate SSL certificates as well.&#x20;

Instead of configuring each package separately, we're using this package that will hold all of the Nginx configuration.

It will generate Staging or Production certificates from Let's Encrypt to ensure a secure connection (in case we require SSL to be enabled).

It is responsible for routing network traffic to the correct service.&#x20;

## Structure of Reverse Proxy Nginx package

The current package contains the following:&#x20;

* `config`: A folder that contains the general Nginx config for secure and insecure mode.
* `package-conf-insecure`: A folder that contains all the insecure configs related to the services that need outside access.
* `package-conf-secure`: A folder that contains all the secure configs related to the services that need outside access.

A job using Ofelia exists to renew the certificates automatically based on the certificate renewal period.

{% hint style="info" %}
Adding new packages that require external access will require adding the Nginx config needed in this package.
{% endhint %}

