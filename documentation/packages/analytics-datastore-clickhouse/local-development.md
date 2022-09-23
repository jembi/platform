---
description: Clickhouse is a SQL datastore
---

# Local Development

### Launching

Launching this package executes the following two steps:&#x20;

* Running Clickhouse service
* Running config importer to run the initial SQL script

### Initializing ClickHouse

The config importer will be launched to run a NodeJS script after ClickHouse has started.

It will run SQL queries to initialize the tables and the schema, and can also include initial seed data if required.

The config importer looks for two files `clickhouseTables.js` and `clickhouseConfig.js` found in `<path to project packages>/analytics-datastore-clickhouse/importer/config.`

For specific implementation, this folder can be overridden.
