# Master Patient Index

This recipe sets up an HIE that deploys JeMPI behind the OpenHIM with a mapping mediator configured to allow for FHIR-based communication with JeMPI. It also deploys Keycloak for user management and authentication.

To launch this package in dev mode copy and paste this into your terminal in a new folder (ensure you have the [instant CLI installed](https://jembi.gitbook.io/instant-v2/getting-started/quick-start)):

```bash
wget https://raw.githubusercontent.com/jembi/platform/recipes/mpi.env && \
wget https://raw.githubusercontent.com/jembi/platform/recipes/config.yaml && \
instant package init -p mpi --dev
```
