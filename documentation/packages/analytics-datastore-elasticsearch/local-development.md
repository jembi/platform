---
description: Elasticsearch is the datastore for the Elastic (ELK) Stack
---

# Local Development

### Launching

Launching this package follows different steps:&#x20;

* \[Cluster mode] Creating certificates and configuring the nodes&#x20;
* Running Elasticsearch
* Setting Elasticsearch passwords
* Importing Elasticsearch index

### Importing

To initialize the index mapping in Elasticsearch, a helper container is launched to import a config file to Elasticsearch. The config importer looks for a field named `fhir-enrich-report.json` in `<path to project packages>/analytics-datastore-elastic-search/importer`.

The file `fhir-enrich-report.json` will contain the mapping of the index `fhir-enrich-reports`.&#x20;

Elasticsearch will create a dynamic mapping for the incoming data if we don't specify one, this dynamic mapping may cause issues when we start sending the data as it doesn't necessarily conform 100% to the data types that we're expecting when querying the data out of Elasticsearch again.

Therefore, the mapping should be initialized in Elasticsearch using the config importer.&#x20;

The file `fhir-enrich-report.json` is just an example, the name and the mapping can be overridden.

### Running in Dev Mode

When running in DEV mode, Elasticsearch is reachable at:

> `http://127.0.0.1:9201/`

### Elasticsearch Backups

For detailed steps about creating backups see: [Snapshot filesystem repository docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-filesystem-repository.html).

Elasticsearch offers the functionality to save a backup in different ways, for further understanding, you can use this link: [Register a snapshot repository docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html).

### Elasticsearch Restore

To see how to restore snapshots in Elasticsearch: [Snapshot Restore docs](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html#snapshots-restore-snapshot).
