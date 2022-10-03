---
description: Generic Logstash pipeline for ELK stack.
---

# Local Development

## Adding pipelines and configs

To add Logstash config files, you can add files into the `<path to project packages>/data-mapper-logstash/pipeline.`

## Developing the Logstash configs locally

When seeking to make changes to the Logstash configs without having to repeatedly start and stop the service, one can set the `LOGSTASH_DEV_MOUNT` env var in your .env file to `true` to attach the service's config files to those on your local machine.

## Cluster

When attaching Logstash to an Elasticsearch cluster ensure you use the `ES_HOSTS` environment variable. eg. `ES_HOSTS="analytics-datastore-elastic-search-1:9200","analytics-datastore-elastic-search-2:9200","analytics-datastore-elastic-search-3:9200"` and reference it in your logstash configs eg. `hosts => [$ES_HOSTS]`

### Notes

> * With `LOGSTASH_DEV_MOUNT=true`, you have to set the `LOGSTASH_PACKAGE_PATH` variable with the absolute path to package containing your Logstash config files, i.e., `LOGSTASH_PACKAGE_PATH=/home/user/Documents/Projects/platform/data-mapper-logstash`.
> * WARNING: do not edit the pipeline files from within the Logstash container, or the group ID and user ID will change, and subsequently will result in file permission errors on your local file system.
