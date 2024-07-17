---
description: Listed in this page are all environment variables needed to run Logstash.
---

# Environment Variables



<table><thead><tr><th width="223">Variable Name</th><th width="99">Type</th><th width="201">Relevance</th><th width="126">Required</th><th>Default</th></tr></thead><tbody><tr><td>LOGSTASH_INSTANCES</td><td>Number</td><td>Number of service replicas </td><td>No</td><td>1</td></tr><tr><td>LOGSTASH_DEV_MOUNT</td><td>Boolean</td><td>DEV mount mode enabling flag</td><td>No</td><td>false</td></tr><tr><td>LOGSTASH_PACKAGE_PATH</td><td>String</td><td>Logstash package absolute path</td><td>yes if <code>LOGSTASH_DEV_MOUNT</code> is true</td><td></td></tr><tr><td>LS_JAVA_OPTS</td><td>String</td><td>JVM heap size, it should be no less than 4GB and no more than 8GB (maximum of 50-75% of total RAM)</td><td>No</td><td>-Xmx2g -Xms2g</td></tr><tr><td>ES_ELASTIC</td><td>String</td><td>ElasticSearch Logstash user password</td><td>Yes</td><td>dev_password_only</td></tr><tr><td>ES_HOSTS</td><td>String</td><td>Elasticsearch connection string</td><td>Yes</td><td>analytics-datastore-elastic-search:9200</td></tr><tr><td>KIBANA_SSL</td><td>Boolean</td><td>SSL protocol requirement</td><td>No</td><td>True</td></tr><tr><td>LOGSTASH_MEMORY_LIMIT</td><td>String</td><td>RAM usage limit</td><td>No</td><td>3G</td></tr><tr><td>LOGSTASH_MEMORY_RESERVE</td><td>String</td><td>Reserved RAM</td><td>No</td><td>500M</td></tr></tbody></table>
