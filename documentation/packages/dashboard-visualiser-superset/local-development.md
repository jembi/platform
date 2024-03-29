# Local Development

## Accessing the Service <a href="#accessing-the-service" id="accessing-the-service"></a>

Superset - [http://127.0.0.1:8089/](http://127.0.0.1:8089/)

## Using the superset\_config.py file <a href="#using-the-superset_config.py-file" id="using-the-superset_config.py-file"></a>

The Superset package is configured to contain a superset\_config.py file, which Superset looks for, and subsequently activates the contained feature flags. For more information on the allowed feature flags, visit [https://github.com/apache/superset/blob/master/RESOURCES/FEATURE\_FLAGS.md](https://github.com/apache/superset/blob/master/RESOURCES/FEATURE\_FLAGS.md).

## Importing & Exporting Assets <a href="#importing-and-exporting-assets" id="importing-and-exporting-assets"></a>

The config importer written in JS will import the file `superset-export.zip` that exists in the folder `<path to project packages>/dashboard-visualiser-superset/importer/config.` The assets that will be imported to Superset are the following:

* The link to the Clickhouse database
* The dataset saved from Clickhouse DB
* The dashboards
* The charts

If you made any changes to these objects please don't forget to export and save the file as `superset-export.zip` under the folder specified above. NB! It is not possible to export all these objects from the Superset UI, you can check the Postman collection: `CARES DISI CDR -> Superset export assets` and you will find two requests. To do the export, three steps are required:

1. Run the `Get Token Superset` request to get the token (please make sure that you are using the correct request URL). An example of a response from Superset that will be displayed: `{ "access_token": "eyJ0eXAiOiJKV1...." }`
2. Copy the access token and put it into the second request `Export superset assets` in the Authorization section.
3. Run the second request `Export superset assets` . You can save the response into a file called `superset-export.zip` under the folder specified above.

Your changes should then be saved.
