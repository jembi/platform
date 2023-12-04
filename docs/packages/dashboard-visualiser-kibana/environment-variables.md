---
description: Listed in this page are all environment variables needed to run Kibana.
---

# Environment Variables

<table><thead><tr><th width="263">Variable Name</th><th width="96">Type</th><th width="171">Relevance</th><th width="102">Required</th><th>Default</th></tr></thead><tbody><tr><td>ES_KIBANA<em>_</em>SYSTEM</td><td>String</td><td>ElasticSearch auth username</td><td>Yes</td><td></td></tr><tr><td>KIBANA_INSTANCES</td><td>Number</td><td>Number of service replicas </td><td>No</td><td>1</td></tr><tr><td>KIBANA_YML<em>_</em>CONFIG</td><td>String</td><td>Path to the service configuration file</td><td>No</td><td>kibana-kibana.yml </td></tr><tr><td>KIBANA_USERNAME</td><td>String</td><td>Service username</td><td>No</td><td>elastic</td></tr><tr><td>KIBANA_PASSWORD</td><td>String</td><td>Service password</td><td>No</td><td>dev_password_only</td></tr><tr><td>KIBANA_SSL</td><td>Boolean</td><td>SSL protocol requirement</td><td>No</td><td>True</td></tr><tr><td>KIBANA_CONFIG<em>_</em>FILE</td><td>String</td><td>Path to the dashboard import file</td><td>No</td><td>kibana-export.ndjson</td></tr><tr><td>KIBANA_MEMORY<em>_</em>LIMIT</td><td>String</td><td>RAM usage limit</td><td>No</td><td>3G</td></tr><tr><td>KIBANA_MEMORY<em>_</em>RESERVE</td><td>String</td><td>Reserved RAM</td><td>No</td><td>500M</td></tr></tbody></table>
