---
description: Backup & restore process.
---

# Disaster Recovery Process

Two major procedures should exist in order to recover lost data:

* Creating backups continuously&#x20;
* Restoring the backups

This includes the different databases: MongoDB, PostgreSQL DB and Elasticsearch.

The current implementation will create continuous backups for MongoDB (to backup all the transactions of OpenHIM) and PostgreSQL (to backup the HAPI FHIR data) as follows:

* Daily backups (for 7 days rotation)&#x20;
* Weekly backups (for 4 weeks rotation)&#x20;
* Monthly backups (for 3 months rotation)

More details on each service backup & restore pages.
