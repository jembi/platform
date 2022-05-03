# Data Mapper - Logstash

## Developing the logstash configs locally

When seeking to make changes to the logstash configs without having to repeatedly start and stop the service, one can set the `LOGSTASH_DEV_MOUNT`
env var in your .env file to `true` to attach the service's config files to those on your local machine.

## Notes

- With `LOGSTASH_DEV_MOUNT=true`, you have to set the `LOGSTASH_PACKAGE_PATH` variable with the absolute path to package containing your Logstash config files, i.e., `LOGSTASH_PACKAGE_PATH=/home/user/Documents/Projects/platform/data-mapper-logstash`.
- If running into a `permission denied` problem for editing the Logstash config files, try editing those files from within the container instead (changes will still reflect on your local files). To edit files from within the container (using VS Code), make sure you have the Docker extension installed, then open the Logstash container's file system from within the Docker extension tab, navigate to the config-file location, then right-click on the desired file to open it - you can edit that file directly.
