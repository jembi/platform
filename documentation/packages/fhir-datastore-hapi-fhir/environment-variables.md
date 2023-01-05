---
description: >-
  Listed in this page are all environment variables needed to run hapi-fhir
  package.
---

# Environment Variables

| Variable Name                 | Type   | Revelance                                                         | Required | Default         |
| ----------------------------- | ------ | ----------------------------------------------------------------- | -------- | --------------- |
| REPMGR\_PRIMARY\_HOST         | String | Service name of the primary replication manager host (PostgreSQL) | No       | postgres-01      |
| REPMGR\_PARTNER\_NODES        | String | Service names of the replicas of PostgreSQL                       | Yes      | postgres-01      |
| POSTGRES\_REPLICA\_SET        | String | PostgreSQL replica set (host and port of the replicas)            | Yes      | postgres-01:5432 |
| HAPI\_FHIR\_CPU\_LIMIT        | Number | CPU limit usage for hapi-fhir service                             | No       | 0 (unlimited)   |
| HAPI\_FHIR\_CPU\_RESERVE      | Number | Reserved CPU usage for hapi-fhir service                          | No       | 0.05            |
| HAPI\_FHIR\_MEMORY\_LIMIT     | String | RAM limit usage for hapi-fhir service                             | No       | 3G              |
| HAPI\_FHIR\_MEMORY\_RESERVE   | String | Reserved RAM usage for hapi-fhir service                          | No       | 500M            |
| HF\_POSTGRES\_CPU\_LIMIT      | Number | CPU limit usage for postgreSQL service                            | No       | 0 (unlimited)   |
| HF\_POSTGRES\_CPU\_RESERVE    | Number | Reserved CPU usage for postgreSQL service                         | No       | 0.05            |
| HF\_POSTGRES\_MEMORY\_LIMIT   | String | RAM limit usage for postgreSQL service                            | No       | 3G              |
| HF\_POSTGRES\_MEMORY\_RESERVE | String | Reserved RAM usage for hapi-fhir service                          | No       | 500M            |
| HAPI\_FHIR\_INSTANCES         | Number | Number of hapi-fhir service replicas                              | No       | 1               |
| HF\_POSTGRESQL\_USERNAME      | String | Hapi-fhir PostgreSQL username                                     | Yes      | admin           |
| HF\_POSTGRESQL\_PASSWORD      | String | Hapi-fhir PostgreSQL password                                     | Yes      | instant101      |
| HF\_POSTGRESQL\_DATABASE      | String | Hapi-fhir PostgreSQL database                                     | No       | hapi            |
| REPMGR\_PASSWORD              | Strign | hapi-fhir PostgreSQL Replication Manager username                 | Yes      |                 |
