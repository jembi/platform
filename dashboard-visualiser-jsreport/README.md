# Dashboard Visualiser - JS Reports

JS Reports is a visualisation tool, which in our use case, is querying information from Elasticsearch.

## Accessing the services

- JS Reports <http://localhost:5488/> - (u: admin p: dev_password_only) - for pixel-perfect PDF reporting

## Developing the JS Report scripts/templates locally

When seeking to make changes to the JS Report scripts/templates without having to repeatedly start and stop the service, one can set the `JS_REPORT_DEV_MOUNT`
env var in your .env file to `true` to attach the service's content files to those on your local machine.

- You have to run the `set-permissions.sh` script before launching JS Report when `JS_REPORT_DEV_MOUNT=true`.
- `NB!!! REMEMBER TO EXPORT THE JSREXPORT FILE WHEN YOU'RE DONE EDITING THE SCRIPTS` (https://jsreport.net/learn/import-export)

## Notes

- With `JS_REPORT_DEV_MOUNT=true`, you have to set the `JS_REPORT_PACKAGE_PATH` variable with the absolute path to the JS Report package on your local machine, i.e., `LOGSTASH_PACKAGE_PATH=/home/user/Documents/Projects/platform/dashboard-visualiser-jsreport`.

- Remember to shutdown JS Report before changing git branches if `JS_REPORT_DEV_MOUNT=true`, otherwise the dev mount will persist the JS Report scripts/templates across your branches.

