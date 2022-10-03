---
description: A FHIR compliant server for the platform.
---

# Local Development

## Instant OpenHIE FHIR Data Store Component

This component consists of two services:

* Postgres
* HAPI FHIR Server - [HAPI FHIR](https://hapifhir.io/)

### Accessing the services

#### HAPI FHIR

This service is accessible for testing via:

[http://127.0.0.1:3447](http://{broad\_cast\_ip}:3447)

In a publicly accessible deployment this port should not be exposed. The OpenHIM should be used to access HAPI-FHIR.

### Testing the HAPI FHIR Component

For testing this component we will be making use of `curl` for sending our request, but any client could be used to achieve the same result.

Execute the command below

```bash
curl http://127.0.0.1:3447/fhir/Patient
```
