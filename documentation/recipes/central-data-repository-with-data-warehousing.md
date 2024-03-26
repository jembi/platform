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
wget https://raw.githubusercontent.com/jembi/platform/main/cdr-dw.env && \
wget https://raw.githubusercontent.com/jembi/platform/main/config.yaml && \
instant package init -p cdr-dw --dev
```

## Services

When deployed in `--dev` mode the location of the UIs will be as follows:

| Service  | URL                                                                                                                        | Auth                                                  |
| -------- | -------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| OpenHIM  | [http://localhost:9000/](http://localhost:9000/)                                                                           | <p>Test SSO user:<br>u: test p: dev_password_only</p> |
| JeMPI    | [http://localhost:3033/](http://localhost:3033/)                                                                           | <p>Test SSO user:<br>u: test p: dev_password_only</p> |
| Superset | [http://localhost:8089/](http://localhost:8089/)                                                                           | <p>Test SSO user:<br>u: test p: dev_password_only</p> |
| Grafana  | [http://localhost:3000/](http://localhost:3000/)                                                                           | <p>Test SSO user:<br>u: test p: dev_password_only</p> |
| Keycloak | [http://localhost:9088/admin/master/console/#/platform-realm](http://localhost:9088/admin/master/console/#/platform-realm) | u: admin p: dev\_password\_only                       |

Extra UIs only exposed in `--dev` mode:

| Service   | URL                                              | Auth |
| --------- | ------------------------------------------------ | ---- |
| Kafdrop   | [http://localhost:9013/](http://localhost:9013/) | none |
| HAPI FHIR | [http://localhost:3447/](http://localhost:3447/) | none |

## Example use

Use the following example postman collection to see interaction you cna have with the system and see how the system reacts.

{% embed url="https://www.postman.com/jembi-platform/workspace/jembi-public/collection/23372581-055117db-6827-43d8-bc50-86f06f5a54c6?action=share&creator=23372581" %}
