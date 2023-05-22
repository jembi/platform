---
description: What is the Jembi Platform and what can you use it for?
---

# About

Jembi platform is an easy was to setup, manage and operate a Health Information Exchange (HIE). Specifically it is the following:

* A toolbox of open-source tools, grouped into packages, that are used to in an HIE.
* The glue that ties these tools together. These are often in the form of OpenHIM mediators which are just microservices that talk to the OpenHIM.
* A CLI tool to deploy and manage these packages.

### The Problem <a href="#the-problem" id="the-problem"></a>

We at Jembi want to stop rebuilding solutions from near scratch each time we need an HIE implementation. It would beneficial to us and other doing the same work to focus more on the unique needs of a country rather than the intricacies of a production deployment of an HIE.

Operating production-grade HIE systems is hard, because of these issues:

* Need to support up to national scale
* An always present need for high level of security
* Difficult of deploying complex system that have many components
* Considerations for high availability/fault tolerance
* Setting up monitoring all services within the HIE
* Common HIE services require very specific knowledge, i.e.:
  * Patient matching
  * Efficient reporting
  * Data standards

### The Solution <a href="#the-solution" id="the-solution"></a>

Jembi Platform provides an opinionated way to to deploy, secure and scale highly-available services for an HIE environment. It provides a set of services to solve common HIE challenges:

* Patient matching
* FHIR support
* Reporting services
* Extensible for country needs
* Deploying/Operating/Managing HIE services
