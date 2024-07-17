---
description: Listed in this page are all environment variables needed to run Hapi-proxy.
---

# Environment Variables

<table><thead><tr><th width="244">Variable Name</th><th width="96">Type</th><th width="171">Relevance</th><th width="102">Required</th><th>Default</th></tr></thead><tbody><tr><td>HAPI_SERVER_URL</td><td>String</td><td>Hapi-fhir server URL</td><td>No</td><td>http://hapi-fhir:8080/fhir</td></tr><tr><td>KAFKA_BOOTSTRAP_SERVERS</td><td>String</td><td>Kafka server</td><td>No</td><td>kafka:9092</td></tr><tr><td>HAPI_SERVER_VALIDATE_FORMAT</td><td>String</td><td>Path to the service configuration file</td><td>No</td><td>kibana-kibana.yml </td></tr><tr><td>HAPI_PROXY_INSTANCES</td><td>Number</td><td>Number of instances of hapi-proxy</td><td>No</td><td>1</td></tr><tr><td>HAPI_PROXY_CPU_LIMIT</td><td>Number</td><td>CPU usage limit</td><td>No</td><td>0</td></tr><tr><td>HAPI_PROXY_CPU_RESERVE</td><td>Number</td><td>Reserved CPU usage</td><td>No</td><td>0.05</td></tr><tr><td>HAPI_PROXY_MEMORY_LIMIT</td><td>String</td><td>RAM usage limit</td><td>No</td><td>3G</td></tr><tr><td>HAPI_PROXY_MEMORY_RESERVE</td><td>String</td><td>Reserved RAM</td><td>No</td><td>500M</td></tr></tbody></table>
