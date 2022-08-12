
# Interoperability Layer - OpenHIM

The Interoperability Layer is the base of the Platform architecture.

This component consists of two services:

* Interoperability Layer - [OpenHIM](http://openhim.org/)

## Accessing the services

### OpenHIM

* Console: <http://localhost:9000>
* Username: **root@openhim.org**
* Password: **instant101**

## Testing the Interoperability Component

As part of the Interoperability Layer setup we also do some initial config import for connecting the services together.

* OpenHIM: Import a channel configuration that routes requests to the Data Store - HAPI FHIR service

## Backup restore

[Single node restore](https://www.mongodb.com/docs/v4.2/tutorial/backup-and-restore-tools/)
[Cluster restore](https://www.mongodb.com/docs/v4.2/tutorial/restore-replica-set-from-backup/)
