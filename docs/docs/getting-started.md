---
sidebar_position: 3
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

# Getting Started

## Requirements

Install [Docker](https://www.docker.com/get-started/)

## Steps for initialising a new platform project

Create a new directory for your project
```bash 
mkdir my-project && cd my-project
```

Create the following files in your project directory:

```yml title="config.yml"
---
image: org/my-project
platformVersion: 1.4.3
defaultTargetLauncher: swarm
disableKubernetes: true
disableIG: true
disableCustomTargetSelection: true
packages:
  - id: interoperability-layer-openhim
    name: Interoperability Layer - OpenHIM
  - id: reverse-proxy-nginx
    name: Reverse Proxy - NGINX
  - id: fhir-datastore-hapi-fhir
    name: FHIR Data Store - HAPI-FHIR
  - id: message-bus-kafka
    name: Message Bus - Kafka
  - id: analytics-datastore-elastic-search
    name: Analytics Datastore - ElasticSearch
  - id: dashboard-visualiser-kibana
    name: Dashboard Visualiser - Kibana
  - id: data-mapper-logstash
    name: Data Mapper - Logstash
  - id: message-bus-helper-hapi-proxy
    name: Message Bus Helper Package - Hapi Proxy
  - id: dashboard-visualiser-jsreport
    name: Dashboard Visualiser - JS Reports

```

```bash title=".env.local"
# General

STATEFUL_NODES=single

# Interoperability Layer - OpenHIM

OPENHIM_CORE_INSTANCES=1
OPENHIM_CONSOLE_INSTANCES=1
OPENHIM_CORE_MEDIATOR_HOSTNAME=localhost
OPENHIM_MEDIATOR_API_PORT=8080
MONGO_SET_COUNT=3

# FHIR Datastore - HAPI FHIR

HAPI_FHIR_INSTANCES=1
REPMGR_PRIMARY_HOST=postgres-1
REPMGR_PARTNER_NODES=postgres-1,postgres-2,postgres-3
POSTGRES_REPLICA_SET=postgres-1:5432,postgres-2:5432,postgres-3:5432

# Reverse Proxy - Nginx

REVERSE_PROXY_INSTANCES=3
INSECURE=true
INSECURE_PORTS=-5001:5001-80:80-8080:8080-5601:5601-5488:5488
DOMAIN_NAME=domain
SUBDOMAINS=openhimcomms.domain,openhimcore.domain,openhimconsole.domain,kibana.domain,reports.domain
RENEWAL_EMAIL=dummy@jembi.org
STAGING=true

# Analytics Datastore - Elastic Search

ES_HEAP_SIZE=-Xms2048m -Xmx2048m
ES_LOGSTASH_SYSTEM=dev_password_only
ES_APM_SYSTEM=dev_password_only
ES_REMOTE_MONITORING_USER=dev_password_only
ES_ELASTIC=dev_password_only
ES_KIBANA_SYSTEM=dev_password_only
ES_BEATS_SYSTEM=dev_password_only
ES_SSL=false

# Dashboard Visualiser - Kibana

# ES_KIBANA_SYSTEM - Required for Kibana, set in the "Analytics Datastore - Elastic Search" section
KIBANA_INSTANCES=1
KIBANA_SSL=false

# Data Mapper - Logstash

# ES_ELASTIC - Required for Logstash, set in the "Analytics Datastore - Elastic Search" section
LS_JAVA_OPTS=-Xmx2g -Xms2g

# Dashboard Visualiser - JS Reports

JS_REPORT_INSTANCES=1
JS_REPORT=dev_password_only
JS_REPORT_USERNAME=admin
JS_REPORT_SECRET=dev_secret_only
JS_REPORT_SSL=false
JS_REPORT_CONFIG_FILE=export.jsrexport

```

Download the version of the platform cli that you wish to use ([available releases](https://github.com/openhie/package-starter-kit/releases))

<Tabs>
<TabItem value="linux" label="Linux">

```bash
curl -L https://github.com/openhie/package-starter-kit/releases/download/0.4.0/gocli-linux -o platform && chmod +x ./platform
```

</TabItem>
<TabItem value="macos" label="Mac OS">

```bash
curl -L https://github.com/openhie/package-starter-kit/releases/download/0.4.0/gocli-macos -o platform && chmod +x ./platform
```

</TabItem>
<TabItem value="windows" label="Windows">

```bash
curl -L https://github.com/openhie/package-starter-kit/releases/download/0.4.0/gocli.exe -o platform.exe && chmod +x ./platform.exe
```

</TabItem>
</Tabs>

Launch the platform by selecting 
```bash
./platform init --dev --env-file=.env.local
```
