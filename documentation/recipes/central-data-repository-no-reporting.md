# Central Data repository (no reporting)

This recipe sets up an HIE that does the following:

* Accept FHIR bundles submitted securely through an IOL (OpenHIM)
* Stores Clinical FHIR data to a FHIR store (HAPI FHIR)
* Stores Patient Demographic data to an MPI (JeMPI)
* Pushes FHIR resources to Kafka for other external systems to use

To launch this package in dev mode copy and paste this into your terminal in a new folder (ensure you have the [instant CLI installed](https://jembi.gitbook.io/instant-v2/getting-started/quick-start)):

```bash
wget https://raw.githubusercontent.com/jembi/platform/recipes/cdr.env && \
wget https://raw.githubusercontent.com/jembi/platform/recipes/config.yaml && \
instant package init -p cdr --dev
```
