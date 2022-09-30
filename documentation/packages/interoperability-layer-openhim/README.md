---
description: >-
  The interoperability layer that enables simpler data exchange between the
  different systems. It is also the security layer for the other systems.
---

# Interoperability Layer Openhim

This component consists of two services:

* Interoperability Layer - [OpenHIM](http://openhim.org/) for routing the events
* Mongo DB for storing the transactions

It provides an interface for:&#x20;

1. Checking the transactions logs&#x20;
2. Configuring the channels to route the events
3. User authentication logs
4. Service logs
5. Rerun the transactions tasks&#x20;
6. Reprocess mediator launching

OpenHIM is based on two 3 main services, openhim-core as a backend, openhim-console as a frontend and mongo as a database.

It is a mandatory component in the stack and the entry point for all incoming requests from the external systems.
