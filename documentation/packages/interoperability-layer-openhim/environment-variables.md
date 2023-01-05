---
description: >-
  Listed in this page are all environment variables needed to run the
  interoperability layer Openhim.
---

# Environment Variables

| Variable Name                     | Type   | Relevance                               | Required | Default                         |
| --------------------------------- | ------ | --------------------------------------- | -------- | ------------------------------- |
| OPENHIM\_CORE\_MEDIATOR\_HOSTNAME | String | Hostname of the Openhim mediator        | Yes      | localhost                       |
| OPENHIM\_MEDIATOR\_API\_PORT      | Number | Port of the Openhim mediator            | Yes      | 8080                            |
| OPENHIM\_CORE\_INSTANCES          | Number | Number of openhim-core instances        | No       | 1                               |
| OPENHIM\_CONSOLE\_INSTANCES       | String | Number of openhim-console instances     | No       | 1                               |
| OPENHIM\_MONGO\_URL               | String | MongoDB connection string               | Yes      | mongodb://mongo-01:27017/openhim |
| OPENHIM\_MONGO\_ATNAURL           | String | ???????????                             | Yes      | mongodb://mongo-01:27017/openhim |
| OPENHIM\_CPU\_LIMIT               | Number | CPU limit usage for openhim-core        | No       | 0                               |
| OPENHIM\_CPU\_RESERVE             | Number | Reserverd CPU usage for openhim-core    | No       | 0.05                            |
| OPENHIM\_MEMORY\_LIMIT            | String | RAM usage limit for openhim-core        | No       | 3G                              |
| OPENHIM\_MEMORY\_RESERVE          | String | Reserved RAM for openhim-core           | No       | 500M                            |
| OPENHIM\_CONSOLE\_CPU\_LIMIT      | Number | CPU limit usage for openhim-console     | No       | 0                               |
| OPENHIM\_CONSOLE\_CPU\_RESERVE    | Number | Reserverd CPU usage for openhim-console | No       | 0.05                            |
| OPENHIM\_CONSOLE\_MEMORY\_LIMIT   | String | RAM usage limit for openhim-console     | No       | 2G                              |
| OPENHIM\_CONSOLE\_MEMORY\_RESERVE | String | Reserved RAM for openhim-console        | No       | 500M                            |
| OPENHIM\_MONGO\_CPU\_LIMIT        | Number | CPU limit usage for mongo               | No       | 0                               |
| OPENHIM\_MONGO\_CPU\_RESERVE      | Number | Reserverd CPU usage for mongo           | No       | 0.05                            |
| OPENHIM\_MONGO\_MEMORY\_LIMIT     | String | RAM usage limit for mongo               | No       | 3G                              |
| OPENHIM\_MONGO\_MEMORY\_RESERVE   | String | Reserved RAM for mongo                  | No       | 500M                            |
| MONGO\_SET\_COUNT                 | Number | Number of instances of Mongo            | YES      | 1                               |
