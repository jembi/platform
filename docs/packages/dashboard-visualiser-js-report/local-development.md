# Local Development

## Accessing the Service

Jsreport - [http://127.0.0.1:5488/](http://localhost:5488/)&#x20;

## Scripts/Templates Development

When seeking to make changes to the Jsreport scripts/templates without having to repeatedly start and stop the service, one can set the `JS_REPORT_DEV_MOUNT` environment variable in your .env file to `true` to attach the service's content files to those on your local machine.

{% hint style="warning" %}
* You have to run the `set-permissions.sh` script before and after launching Jsreport when `JS_REPORT_DEV_MOUNT=true`.
* REMEMBER TO EXPORT THE JSREXPORT FILE WHEN YOU'RE DONE EDITING THE SCRIPTS. More info is available at [https://jsreport.net/learn/import-export](https://jsreport.net/learn/import-export)&#x20;
{% endhint %}

{% hint style="info" %}
* With `JS_REPORT_DEV_MOUNT=true`, you have to set the `JS_REPORT_PACKAGE_PATH` variable with the absolute path to the Jsreport package on your local machine, i.e., `JS_REPORT_PACKAGE_PATH=/home/user/Documents/Projects/platform/dashboard-visualiser-jsreport`
* Remember to shut down Jsreport before changing git branches if `JS_REPORT_DEV_MOUNT=true`, otherwise, the dev mount will persist the Jsreport scripts/templates across your branches.
{% endhint %}

## Export & Import

After editing the templates in Jsreport, you will need to save these changes, it is advised to export a file containing all the changes named `export.jsrexport` and put it into the folder  `<path to project packages>/dashboard-visualiser-jsreport/importer.`

The config importer of Jsreport will import the `export.jsrexport` and then all the templates, assets, and scripts will be loaded in Jsreport.
