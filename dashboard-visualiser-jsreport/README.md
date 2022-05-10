# Dashboard Visualiser - JS Reports

JS Reports is a visualisation tool, which in our use case, is querying information from Elasticsearch.

## Accessing the services

- JS Reports <http://localhost:5488/> - (u: admin p: dev_password_only) - for pixel-perfect PDF reporting

## Developing the JS Report scripts/templates locally

When seeking to make changes to the JS Report scripts/templates without having to repeatedly start and stop the service, one can set the `JS_REPORT_DEV_MOUNT`
env var in your .env file to `true` to attach the service's content files to those on your local machine.

## Notes

- With `JS_REPORT_DEV_MOUNT=true`, you have to set the `JS_REPORT_PACKAGE_PATH` variable with the absolute path to the JS Report package on your local machine, i.e., `LOGSTASH_PACKAGE_PATH=/home/user/Documents/Projects/platform/dashboard-visualiser-jsreport`.
- If running into a `permission denied` problem when editing the JS Report scripts/templates, try editing those files from within JS Report (http://localhost:5488/) instead - changes will still reflect on your local files.
- Remember to shutdown JS Report before changing git branches if `JS_REPORT_DEV_MOUNT=true`, otherwise the dev mount will persist the JS Report scripts/templates across your branches.
- All the folders/files insde dashboard-visualiser-jsreport/scripts must have `owner_id=100` and `group_id=101` for JS Report to launch with the dev-mount attached.

`NB!!! REMEMBER TO EXPORT THE JSREXPORT FILE WHEN YOU'RE DONE EDITING THE SCRIPTS` (https://jsreport.net/learn/import-export)

## Resource constraints

The code snippet below shows CPU and RAM resource allocations per container, and how to set that in the docker-compose.yml file. The values default as shown below, or can be specified in an environment variable file. CPU is specified as a portion of unity, whereas memory is specified in mega (M) or giga (G) bytes.

```yml
resources:
    limits:
        cpus: ${JS_REPORT_CPU_LIMIT:-0.25}
        memory: ${JS_REPORT_MEMORY_LIMIT:-4G}
    reservations:
        cpus: ${JS_REPORT_CPU_RESERVE:-0.1}
        memory: ${JS_REPORT_MEMORY_RESERVE:-1G}
```
- `limits` defines the maximum amount of resources that the container can use.
- `reservations` defines the minimum amount of resources allocated to the container.
