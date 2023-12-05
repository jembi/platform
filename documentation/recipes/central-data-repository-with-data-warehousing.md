# Central Data Repository with Data Warehousing



{% hint style="warning" %}
Note: This recipe is in a pre-release alpha stage. It's usable but do so at your own risk.
{% endhint %}

This recipe sets up an HIE that does the following:

* Accept FHIR bundles submitted securely through an IOL (OpenHIM)
* Stores Clinical FHIR data to a FHIR store (HAPI FHIR)
* Stores Patient Demographic data to an MPI (JeMPI)
* Pushes FHIR resources to Kafka for the reporting pipeline (and other systems) to use
* Pulls FHIR data out of Kafka and maps it to flattened tables in the Data Warehouse (Clickhouse)
* Allows for the Data Warehouse data to be visualised via a BI tool (Apache Superset)

To launch this package in dev mode copy and paste this into your terminal in a new folder (ensure you have the [instant CLI installed](https://jembi.gitbook.io/instant-v2/getting-started/quick-start)):

```bash
wget https://raw.githubusercontent.com/jembi/platform/recipes/cdr-dw.env && \
wget https://raw.githubusercontent.com/jembi/platform/recipes/config.yaml && \
instant package init -p cdr-dw --dev
```
