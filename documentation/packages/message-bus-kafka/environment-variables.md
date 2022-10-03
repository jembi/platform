---
description: >-
  Listed in this page are all environment variables needed to run the Message
  Bus Kafka.
---

# Environment Variables

| Variable Name              | Type   | Relevance        | Required | Default |
| -------------------------- | ------ | ---------------- | -------- | ------- |
| KAFKA\_INSTANCES           | Number | Service replicas | No       | 1       |
| KAFKA\_CPU\_LIMIT          | Number | CPU usage limit  | No       | 0       |
| KAFKA\_CPU\_RESERVE        | Number | Reserved CPU     | No       | 0.05    |
| KAFKA\_MEMORY\_LIMIT       | String | RAM usage limit  | No       | 3G      |
| KAFKA\_MEMORY\_RESERVE     | String | Reserved RAM     | No       | 500M    |
| KAFKA\_TOPICS              | String | Kafka topics     | Yes      |         |
|                            |        |                  |          |         |
| ZOOKEEPER\_CPU\_LIMIT      | Number | CPU usage limit  | No       | 0       |
| ZOOKEEPER\_CPU\_RESERVE    | Number | Reserved CPU     | No       | 0.05    |
| ZOOKEEPER\_MEMORY\_LIMIT   | String | RAM usage limit  | No       | 3G      |
| ZOOKEEPER\_MEMORY\_RESERVE | String | Reserved RAM     | No       | 500M    |
|                            |        |                  |          |         |
| KMINION\_CPU\_LIMIT        | Number | CPU usage limit  | No       | 0       |
| KMINION\_CPU\_RESERVE      | Number | Reserved CPU     | No       | 0.05    |
| KMINION\_MEMORY\_LIMIT     | String | RAM usage limit  | No       | 3G      |
| KMINION\_MEMORY\_RESERVE   | String | Reserved RAM     | No       | 500M    |
|                            |        |                  |          |         |
| KAFDROP\_CPU\_LIMIT        | Number | CPU usage limit  | No       | 0       |
| KAFDROP\_CPU\_RESERVE      | Number | Reserved CPU     | No       | 0.05    |
| KAFDROP\_MEMORY\_LIMIT     | String | RAM usage limit  | No       | 3G      |
| KAFDROP\_MEMORY\_RESERVE   | String | Reserved RAM     | No       | 500M    |

