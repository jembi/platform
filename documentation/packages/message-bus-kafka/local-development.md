# Local Development

## Kafka **Topics Configuration**

[Using a config importer](https://app.gitbook.com/o/lTiMw1wKTVQEjepxV4ou/s/ozRkSu9v4EJR8LJ8nFIv/config-importing), Kafka's topics are imported to Kafka. The topics are specified using the [KAFKA\_TOPICS environment variable](environment-variables.md), and must be of syntax:&#x20;

`topic` or `topic:partition:replicationFactor` &#x20;

Using topics 2xx, 3xx, and metrics (partition=3, replicationFactor=1) as an example, we would declare:

`KAFKA_TOPICS=2xx,3xx,metrics:3:1`&#x20;

where topics are separated by commas. &#x20;

## Accessing Kafdrop

Kafdrop - [http://127.0.0.1:9013/](http://localhost:9013/)&#x20;
