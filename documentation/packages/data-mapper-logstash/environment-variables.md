---
description: Listed in this page are all environment variables needed to run Logstash.
---

# Environment Variables



| Variable Name             | Type    | Relevance                                                                                          | Required                            | Default                                 |
| ------------------------- | ------- | -------------------------------------------------------------------------------------------------- | ----------------------------------- | --------------------------------------- |
| LOGSTASH\_INSTANCES       | Number  | Number of service replicas                                                                         | No                                  | 1                                       |
| LOGSTASH\_DEV\_MOUNT      | Boolean | DEV mount mode enabling flag                                                                       | No                                  | false                                   |
| LOGSTASH\_PACKAGE\_PATH   | String  | Logstash package absolute path                                                                     | yes if `LOGSTASH_DEV_MOUNT` is true |                                         |
| LS\_JAVA\_OPTS            | String  | JVM heap size, it should be no less than 4GB and no more than 8GB (maximum of 50-75% of total RAM) | No                                  | -Xmx2g -Xms2g                           |
| ES\_ELASTIC               | String  | ElasticSearch Logstash user password                                                               | Yes                                 | dev\_password\_only                     |
| ES\_HOSTS                 | String  | Elasticsearch connection string                                                                    | Yes                                 | analytics-datastore-elastic-search:9200 |
| KIBANA\_SSL               | Boolean | SSL protocol requirement                                                                           | No                                  | True                                    |
| LOGSTASH\_MEMORY\_LIMIT   | String  | RAM usage limit                                                                                    | No                                  | 3G                                      |
| LOGSTASH\_MEMORY\_RESERVE | String  | Reserved RAM                                                                                       | No                                  | 500M                                    |
