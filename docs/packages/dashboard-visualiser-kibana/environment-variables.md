---
description: Listed in this page are all environment variables needed to run Kibana.
---

# Environment Variables



| Variable Name             | Type    | Relevance                              | Required | Default              |
| ------------------------- | ------- | -------------------------------------- | -------- | -------------------- |
| ES\_KIBANA_\__SYSTEM      | String  | ElasticSearch auth username            | Yes      |                      |
| KIBANA\_INSTANCES         | Number  | Number of service replicas             | No       | 1                    |
| KIBANA\_YML_\__CONFIG     | String  | Path to the service configuration file | No       | kibana-kibana.yml    |
| KIBANA\_USERNAME          | String  | Service username                       | No       | elastic              |
| KIBANA\_PASSWORD          | String  | Service password                       | No       | dev\_password\_only  |
| KIBANA\_SSL               | Boolean | SSL protocol requirement               | No       | True                 |
| KIBANA\_CONFIG_\__FILE    | String  | Path to the dashboard import file      | No       | kibana-export.ndjson |
| KIBANA\_MEMORY_\__LIMIT   | String  | RAM usage limit                        | No       | 3G                   |
| KIBANA\_MEMORY_\__RESERVE | String  | Reserved RAM                           | No       | 500M                 |
