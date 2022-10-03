---
description: A Kafka consumer that maps FHIR resources to a flattened data structure
---

# Local Development

## Kafka-mapper-consumer&#x20;

A Kafka processor that will consume messages from Kafka topics. This messages will be mapped according to the mapping defined in the file called `fhir-mapping.json.`&#x20;

This flattened data will be then sent to Clickhouse DB to be stored.

Each topic has its own table mapping, plugin and filter and one topic may be mapped in different ways.

An example of fhir-mapping.json can be found in the package.

Each new message with new ID will be inserted as a new row in the table defined in the mapping. An update of the message will result on update in Clickhouse DB accordingly.\
\
Link to GitHub repo: [https://github.com/jembi/kafka-mapper-consumer](https://github.com/jembi/kafka-mapper-consumer).
