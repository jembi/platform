---
description: Generic Logstash pipeline for ELK stack.
---

# Data Mapper Logstash

Logstash provides a data transformation pipeline for analytics data. In the platform it is responsible for transforming FHIR messages into a flattened object that can be inserted into Elasticsearch.

### Input

Logstash allows for different types of input to read the data: Kafka, HTTP ports, files, etc.

### Filters&#x20;

With a set of filters and plugins, the data can be transformed, filtered, and conditioned.&#x20;

This allows the creation of a structured and flattened object out of many nested and long resources.

Accessing the different fields will be much easier and we will get rid of the unused data.

### Output

To save the data, Logstash provides a set of outputs such as: Elasticsearch, S3, files, etc.
