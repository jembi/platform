# Master Patient Index

{% hint style="warning" %}
Note: This recipe is in a pre-release alpha stage. It's usable but do so at your own risk.
{% endhint %}

This recipe sets up an HIE that deploys JeMPI behind the OpenHIM with a mapping mediator configured to allow for FHIR-based communication with JeMPI. It also deploys Keycloak for user management and authentication.

To launch this package in dev mode copy and paste this into your terminal in a new folder (ensure you have the [instant CLI installed](https://jembi.gitbook.io/instant-v2/getting-started/quick-start)):

```bash
wget https://github.com/jembi/platform/releases/latest/download/mpi.env && \
wget https://github.com/jembi/platform/releases/latest/download/config.yaml && \
instant package init -p mpi --dev
```
