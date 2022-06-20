# Data Mapper - Logstash

## Developing the logstash configs locally

When seeking to make changes to the logstash configs without having to repeatedly start and stop the service, one can set the `LOGSTASH_DEV_MOUNT`
env var in your .env file to `true` to attach the service's config files to those on your local machine.

## Notes

- With `LOGSTASH_DEV_MOUNT=true`, you have to set the `LOGSTASH_PACKAGE_PATH` variable with the absolute path to package containing your Logstash config files, i.e., `LOGSTASH_PACKAGE_PATH=/home/user/Documents/Projects/platform/data-mapper-logstash`.
- WARNING: do not edit the pipeline files from within the logstash container, or the group ID and user ID will change, and subsequently will result in file permission errors on your local file system.
