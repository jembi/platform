# jsreport-config-importer

The JS Report config importer

## Running the config importer

Successful use of the jsreport-config-importer needs the environment variables found in `package-metadata.json`. However, 
if running in dev mode, the `DOMAIN_NAME` variable does not need to be set.

## Making the `export.jsrexport` file

As part of importing configs, a zip file containing templates, scripts, and all associated metadata files, must be created from within JSR and inserted into this package. The file name should default to `export.jsrexport`, but if it doesn't, it should be named as such. Instructions on creating 
the export file can be found at https://jsreport.net/learn/import-export.

