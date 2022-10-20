---
description: The Interoperability Layer is the base of the Platform architecture.
---

# Local Development

### Accessing the services

OpenHIM

* Console: [http://127.0.0.1:9000](http://localhost:9000)
* Username: **root@openhim.org**
* Password: **instant101**

### Testing the Interoperability Component

As part of the Interoperability Layer setup we also do some initial config import for connecting the services together.

* OpenHIM: Import a channel configuration that routes requests to the Data Store - HAPI FHIR service

This config importer will import channels and configuration according to the file `openhim-import.json` in the folder `<path to project packages>/interoperability-layer-openhim/importer/volume.`
