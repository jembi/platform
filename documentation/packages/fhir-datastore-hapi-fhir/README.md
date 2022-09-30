---
description: A FHIR compliant server for the platform.
---

# FHIR Datastore HAPI FHIR

The HAPI FHIR service will be used for two mandatory functionalities:&#x20;

* A validator of FHIR messages
* A storage of FHIR message&#x20;

### A validator

Incoming messages from an EMR or Postman bundles are not always well structured and it may be missing required elements or be malformed.

HAPI FHIR will use a FHIR IG to validate these messages.&#x20;

It will reject any invalid resources and it will return errors according to the IG.&#x20;

HAPI FHIR is the first check to make sure the data injected in the rest of the system conforms to the requirements.

### A storage&#x20;

Backed by a PostgreSQL database, all the validated incoming messages will be stored.&#x20;

This will allow HAPI FHIR to check for correct links and references between the resources, as well as another storage for backups in case the data is lost.&#x20;
