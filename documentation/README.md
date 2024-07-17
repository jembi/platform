---
description: What is the OpenHIM Platform and what can you use it for?
cover: >-
  https://images.unsplash.com/photo-1639815189096-f75717eaecfe?crop=entropy&cs=srgb&fm=jpg&ixid=M3wxOTcwMjR8MHwxfHNlYXJjaHwzfHxjb25uZWN0aW5nJTIwYmxvY2tzJTIwZGlnaXRhbHxlbnwwfHx8fDE2OTg4MzAyNjl8MA&ixlib=rb-4.0.3&q=85
coverY: 0
layout: landing
---

# OpenHIM Platform

{% embed url="https://youtu.be/37MvrolxHto" fullWidth="false" %}

OpenHIM platform is an easy way to set up, manage and operate a Health Information Exchange (HIE). Specifically, it is the following:

* A toolbox of open-source tools, grouped into packages, that are used within an HIE.
* The glue that ties these tools together. These are often in the form of OpenHIM mediators which are just microservices that talk to OpenHIM.
* A CLI tool to deploy and manage these packages.

{% content-ref url="README (1).md" %}
[README (1).md](<README (1).md>)
{% endcontent-ref %}

### The Problem <a href="#the-problem" id="the-problem"></a>

We at Jembi want to stop rebuilding solutions from near scratch each time we need an HIE implementation. It would be beneficial to us and others doing the same work to focus more on the unique needs of a country rather than the intricacies of a production deployment of an HIE.

Operating production-grade HIE systems is hard, because of these issues:

* Need to support up to national scale
* An always-present need for high level of security
* Difficulty of deploying complex systems that have many components
* Considerations for high availability/fault tolerance
* Setting up monitoring of all services within an HIE
* Common HIE services require very specific knowledge, i.e.:
  * Patient matching
  * Efficient reporting
  * Data standards

### The Solution <a href="#the-solution" id="the-solution"></a>

OpenHIM Platform provides an opinionated way to deploy, secure and scale highly-available services for an HIE environment. It provides a set of services to solve common HIE challenges:

* Patient matching
* FHIR support
* Reporting services
* Extensible for country needs
* Deploying/Operating/Managing HIE services

{% hint style="info" %}
OpenHIM Platform is powered by the [Instant OpenHIE deployment tool](https://jembi.gitbook.io/instant-v2/).
{% endhint %}
