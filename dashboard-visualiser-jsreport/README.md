# Dashboard Visualiser - JS Reports

JS Reports is a visualisation tool, which in our use case, is querying information from Elasticsearch.

## Accessing the services

- JS Reports <http://localhost:5488/> - (u: admin p: dev_password_only) - for pixel-perfect PDF reporting

## Resource constraints

Adjust the CPU and Memory limits allocated to this service, per container. 

- `limits` defines the maximum amount of resources that the container can use.
- `reservations` defines the minimum amount of resources allocated to the container.

```yml
limits:
    cpus: '0.25'
    memory: 4G
reservations:
    cpus: '0.1'
    memory: 1G
```
