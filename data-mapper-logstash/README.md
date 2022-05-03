# Data Mapper - Logstash

## Developing the logstash configs locally

When seeking to make changes to the logstash configs without having to repeatedly start and stop the service, one can set the `LOGSTASH_DEV_MOUNT`
env var to `true` to attach the service's config files to those on your local machine.

NOTE: With `LOGSTASH_DEV_MOUNT=true`, you have to set the `LOCAL_MACHINE_PATH_TO_PROJECT` variable with the absolute path to project containing your logstash config files, i.e., `LOCAL_MACHINE_PATH_TO_PROJECT=/home/user/Documents/Projects/platform`.
