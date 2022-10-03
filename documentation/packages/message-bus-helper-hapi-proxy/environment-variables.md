---
description: Listed in this page are all environment variables needed to run Hapi-proxy.
---

# Environment Variables

| Variable Name                  | Type   | Relevance                              | Required | Default                    |
| ------------------------------ | ------ | -------------------------------------- | -------- | -------------------------- |
| HAPI\_SERVER\_URL              | String | Hapi-fhir server URL                   | No       | http://hapi-fhir:8080/fhir |
| KAFKA\_BOOTSTRAP\_SERVERS      | String | Kafka server                           | No       | kafka:9092                 |
| HAPI\_SERVER\_VALIDATE\_FORMAT | String | Path to the service configuration file | No       | kibana-kibana.yml          |
| HAPI\_PROXY\_INSTANCES         | Number | Number of instances of hapi-proxy      | No       | 1                          |
| HAPI\_PROXY\_CPU\_LIMIT        | Number | CPU usage limit                        | No       | 0                          |
| HAPI\_PROXY\_CPU\_RESERVE      | Number | Reserved CPU usage                     | No       | 0.05                       |
| HAPI\_PROXY\_MEMORY\_LIMIT     | String | RAM usage limit                        | No       | 3G                         |
| HAPI\_PROXY\_MEMORY\_RESERVE   | String | Reserved RAM                           | No       | 500M                       |
