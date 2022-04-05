# Dashboard Visualiser - JS Reports

JS Reports is a visualisation tool, which in our use case, is querying information from Elasticsearch.

## Accessing the services

- JS Reports <http://localhost:5488/> - (u: admin p: dev_password_only) - for pixel-perfect PDF reporting

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
