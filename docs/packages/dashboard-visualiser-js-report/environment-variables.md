---
description: Listed in this page are all environment variables needed to run Jsreport.
---

# Environment Variables



| Variable Name               | Type    | Relevance                                                                                            | Required                                    | Default                                 |
| --------------------------- | ------- | ---------------------------------------------------------------------------------------------------- | ------------------------------------------- | --------------------------------------- |
| JS\_REPORT\_LICENSE\_KEY    | String  | Service license key                                                                                  | Yes                                         |                                         |
| JS\_REPORT                  | String  | Jsreport service password                                                                            | No                                          | dev\_password\_only                     |
| JS\_REPORT\_USERNAME        | String  | Jsreport service username                                                                            | No                                          | admin                                   |
| JS\_REPORT\_SECRET          | String  | Secret password for the authentication of a cookie session related to the extension used in Jsreport | No                                          | dev\_secret\_only                       |
| ES\_HOSTS                   | String  | Elasticsearch connection string                                                                      | No                                          | analytics-datastore-elastic-search:9200 |
| ES\_PASSWORD                | String  | Elasticsearch password (for request authentication)                                                  | No                                          | dev\_password\_only                     |
| ES\_USERNAME                | String  | Elasticsearch username (for request authentication                                                   | No                                          | elastic                                 |
| JS\_REPORT\_INSTANCES       | Number  | Number of service replicas                                                                           | No                                          | 1                                       |
| JS\_REPORT\_SSL             | Boolean | SSL protocol requirement                                                                             | No                                          | false                                   |
| JS\_REPORT\_CONFIG\_FILE    | String  | Path to the service import file                                                                      | No                                          | export.jsrexport                        |
| JS\_REPORT\_DEV\_MOUNT      | Boolean | Dev mount mode enabling flag                                                                         | No                                          | false                                   |
| JS\_REPORT\_PACKAGE\_PATH   | String  | Local path to package                                                                                | Yes if `JS_REPORT_DEV_MOUNT` is set to true |                                         |
| JS\_REPORT\_CPU\_LIMIT      | Number  | CPU usage limit                                                                                      | No                                          | 0                                       |
| JS\_REPORT\_MEMORY\_LIMIT   | String  | RAM usage limit                                                                                      | No                                          | 3G                                      |
| JS\_REPORT\_CPU\_RESERVE    | Number  | Reserved CPU                                                                                         | No                                          | 0.05                                    |
| JS\_REPORT\_MEMORY\_RESERVE | String  | Reserved RAM                                                                                         | No                                          | 500M                                    |
