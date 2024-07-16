# Reverse Proxy Traefik

The package is an alternative reverse proxy nginx, this reverse proxy exposes packages using both subdomains and subdirectory to host the following services:

| Package  | Hosted                                                                                                 |
| -------- | ------------------------------------------------------------------------------------------------------ |
| Superset | Sub Domain (e.g. superset.<domain>)                                                                    |
| Jempi    | Sub Domain (e.g. jembi.<domain>)                                                                       |
| Santempi | Sub Domain (e.g. santempi.<domain>)                                                                    |
| Kibana   | Sub Domain (e.g. kibana.<domain>)                                                                      |
| Minio    | Sub Directory (e.g. monitoring.<domain>/minio)                                                         |
| Grafana  | Sub Directory (e.g. monitoring.<domain>/grafana)                                                       |
| JSReport | Sub Directory (e.g. monitoring.<domain>/jsreport)                                                      |
| OpenHim  | Sub Domain (Frontend) Sub Directory (Backend) (e.g. openhim.<domain> and openhim.<domain>/openhimcore) |

## Domain Based Reverse Proxy

The following packages do not support subdomain and require the uses of domain/subdomain to access over the reverse proxy

### Superset

Set the following environment variable in the package-metadata.json in the "./dashboard-visualiser-superset" directory

```bash
"environmentVariables":
{
# Other Configurations
...
    "SUPERSET_TRAEFIK_HOST_NAME": "superset-health.org"
}
```

### Jempi

Set the following environment variables in the package-metadata.json in the "./client-registry-jempi" directory

```bash
"environmentVariables":
{
# Other Configurations
...
    "REACT_APP_JEMPI_BASE_API_HOST": "jempi-api-health.org",
    "REACT_APP_JEMPI_BASE_API_PORT": "443",
    "JEMPI_API_TRAEFIK_HOST_NAME": "jempi-api-health.org",
    "JEMPI_WEB_TRAEFIK_HOST_NAME": "jempi-web-health.org",
}
```

### Santempi

Set the following environment variables in the package-metadata.json in the "./client-registry-santempi" directory

```bash
"environmentVariables":
{
# Other Configurations
...
    "SANTEDB_WWW_TRAEFIK_HOST_NAME": "santewww-health.org",
    "SANTEDB_MPI_TRAEFIK_HOST_NAME": "santempi-health.org"
}
```

### Enabling Kibana

Set the following environment variables in the package-metadata.json in the "./dashboard-visualiser-kibana" directory

```bash

"environmentVariables":
{
# Other Configurations
...
    "KIBANA_TRAEFIK_HOST_NAME": "kibana-health.org"
}

```

## Subdirectory

### Enabling Minio

Set the following environment variables in the package-metadata.json in the "monitoring" directory

```bash

"environmentVariables":
{
# Other Configurations
...
    "MINIO_SERVER_DOMAIN": "health.org",
    "MINIO_BROWSER_REDIRECT_URL": "https://health.org/minio/"
}

```

### Enabling Grafana

Set the following environment variables in the package-metadata.json in the "monitoring" directory

```bash

"environmentVariables":
{
# Other Configurations
...
    "KC_GRAFANA_ROOT_URL": "%(protocol)s://%(domain)s/grafana/",
    "GF_SERVER_DOMAIN": "health.org",
    "GF_SERVER_SERVE_FROM_SUB_PATH": "true",
}

```

### JS Report

Set the following environment variables in the package-metadata.json in the "dashboard-visualiser-jsreport" directory

```bash
"environmentVariables":
{
# Other Configurations
...
    "JS_REPORT_HOST": "health.org",
    "JS_REPORT_PATH_PREFIX": "/jsreport"
}
```

### OpenHIM

Set the following environment variables in the package-metadata.json in the "./interoperability-layer-openhim" directory

> Note: Only the Backend services are accessible through subdirectory paths, not the frontend

```bash
"environmentVariables":
{
# Other Configurations
...
    "OPENHIM_HOST_NAME": "health.org",
    "OPENHIM_CONSOLE_BASE_URL": "http://health.org"
    "OPENHIM_CORE_MEDIATOR_HOSTNAME": "health.org/openhimcomms",
    "OPENHIM_MEDIATOR_API_PORT": "443"
}
```
