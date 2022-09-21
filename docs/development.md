# Development

## Adding Packages

* The Go Cli runs all services from the `jembi/platform` docker image. When adding new packages or updating existing packages to Platform you will need to build/update your local `jembi/platform` image. [How to build the image](../documentation/).
* As you add new packages to the platform remember to list them in the `config.yml` file - otherwise the added package will not be detected by the [platform-cli tool](https://app.gitbook.com/o/lTiMw1wKTVQEjepxV4ou/s/TwrbQZir3ZdvejunAFia/).

##
