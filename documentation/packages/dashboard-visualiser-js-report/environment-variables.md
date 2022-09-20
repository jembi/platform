---
description: Listed in this page are all environment variables needed to run JS Report.
---

# Environment Variables

### JS\_REPORT\_INSTANCES

**Relevance**: Number of service replicas&#x20;

**Type**: Number

**Default Value**: 1

### JS\_REPORT

**Relevance**: Service password

**Type**: String

**Default Value**: dev\_password\_only

### JS\_REPORT\_USERNAME

**Relevance**: Service username

**Type**: String

**Default Value**: dev\_password\_only

### JS\_REPORT\_SECRET

**Relevance**: What is this used for?

**Type**: String

**Default Value**: dev\_secret\_only

### &#x20;JS\_REPORT\_SSL

**Relevance**: Required service http protocol

**Type**: Boolean

**Default Value**: false&#x20;

### JS\_REPORT\_CONFIG\_FILE

**Relevance**: Path to the service import file

**Type**: String

**Default Value**: export.jsrexport&#x20;

### JS\_REPORT\_LICENSE\_KEY

**Relevance**: Service license key

**Type**: String

### JS\_REPORT\_DEV\_MOUNT

**Relevance**: Dev mount mode enabling flag

**Type**: Boolean

**Default Value**: false

### JS\_REPORT\_PACKAGE\_PATH

**Relevance**: Local path to package

**Type**: String

### ES\_HOSTS

**Relevance**: ElasticSearch connection string

**Type**: String

**Default Value**: analytics-datastore-elastic-search:9200

### ES\_USERNAME

**Relevance**: ElasticSearch username (for request authentication)

**Type**: String

**Default Value**: elastic

### ES\_PASSWORD

**Relevance**: ElasticSearch password (for request authentication)

**Type**: String

**Default Value**: dev\_password\_only

### JS\_REPORT\_CPU\_LIMIT

**Relevance**: CPU usage limit

**Type**: Number

**Default Value**: 0

### JS\_REPORT\_MEMORY\_LIMIT

**Relevance**: RAM usage limit

**Type**: String

**Default Value**: 3G

### JS\_REPORT\_CPU\_RESERVE

**Relevance**: Reserved CPU

**Type**: Number

**Default Value**: 0.05

### JS\_REPORT\_MEMORY\_RESERVE

**Relevance**: Reserved RAM &#x20;

**Type**: String

**Default Value**: 500M
