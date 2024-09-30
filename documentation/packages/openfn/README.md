# Package Documentation

## Introduction

Welcome to the documentation for the `openfn` package! This package is designed to provide a platform for seamless integration and automation of data workflows. Whether you are a developer, data analyst, or data scientist, this package will help you streamline your data processing tasks.

## Usage

Once you have added the `openfn` package, you can start using it in your projects. Here is how to instantiate the package

`instant package init -n openfn --dev`

## Demo

To get a hands-on experience with the `openfn` package, try out the demo. The demo showcases the package's capabilities and provides a sample project used to export data from CDR to NDR with transformations. It utilizes a Kafka queue and a custom adapter to map Bundles to be compliant with the FHIR Implementation Guide (IG).

### Getting Started

To access the demo, follow these steps:

1. Visit the [OpenFn Demo](http://localhost:4000) website.
2. Use the following demo credentials

```
username: root@openhim.org
password: instant101
```

3. Configure the Kafka trigger
   Change the trigger type from webhook to “Kafka Consumer”
   Enter in configuration details → see [docs](https://docs.google.com/document/d/1cefHnp6IS6zvFwqQs8EsMQo5D4npsoE-S33R4OBpQjI/edit?usp=sharing)
   Kafka topic: {whichever you want to use} (e.g., “cdr-ndr”)
   Hosts: {cdr host name}
   Initial offset reset policy: earliest
   Connection timeout: 30 (default value, but can be adjusted)
   Warning: Check Disable this trigger to ensure that consumption doesn’t start until you are ready to run the workflow! Once unchecked, it will immediately start consuming messages off the topic.

### Documentation

For more detailed information on the `openfn` package and its functionalities, please refer to the [official documentation](https://github.com/openfn/docs). The documentation covers various topics, including installation instructions, usage guidelines, and advanced features.
