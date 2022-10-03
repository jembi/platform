---
description: A kafka processor to unbundle resources into their own kafka topics.
---

# Kafka Unbundler Consumer

The kafka unbundler will consume resources of topix `2xx` from Kafka, split them according to their resource type and send them again to Kafka to new topics.

Each resource type has its own topic.

Link for github repo: [https://github.com/jembi/kafka-unbundler-consumer](https://github.com/jembi/kafka-unbundler-consumer).
