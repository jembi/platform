---
description: Reverse proxy for secure traefik configurations.
---

# Reverse Proxy Traefik

&#x20;

# Reverse Proxy Traefik

The package is an alternative reverse proxy Nginx, this reverse proxy exposes packages using both subdomains and subdirectories to host the following services:

| Package  | Hosted                                                                                                 |
| -------- | ------------------------------------------------------------------------------------------------------ |
| Superset | Sub Domain (e.g. superset.<domain>)                                                                    |
| Jempi    | Sub Domain (e.g. jempi.<domain>)                                                                       |
| Santempi | Sub Domain (e.g. santempi.<domain>)                                                                    |
| Kibana   | Sub Domain (e.g. kibana.<domain>)                                                                      |
| Minio    | Sub Directory (e.g. <domain>/minio)                                                                    |
| Grafana  | Sub Directory (e.g. <domain>/grafana)                                                                  |
| JSReport | Sub Directory (e.g. <domain>/jsreport)                                                                 |
| OpenHim  | Sub Domain (Frontend) Sub Directory (Backend) (e.g. openhim.<domain> and openhim.<domain>/openhimcore) |

> Please ensure that the ENV "DOMAIN_NAME" is set, in this documentation we will be using the placeholder "domain" for its value

## Subdomain-Based Reverse Proxy

The following packages do not support subdomains and require the use of domain/subdomain to access over the reverse proxy

### Superset

Set the following environment variable in the package-metadata.json in the "./dashboard-visualiser-superset" directory

```bash
"environmentVariables":
{
# Other Configurations
...
    "SUPERSET_TRAEFIK_SUBDOMAIN": "superset"
}
```

### Jempi

Set the following environment variables in the package-metadata.json in the "./client-registry-jempi" directory

```bash
"environmentVariables":
{
# Other Configurations
...
    "REACT_APP_JEMPI_BASE_API_HOST": "jempi-api.domain",
    "REACT_APP_JEMPI_BASE_API_PORT": "443",
    "JEMPI_API_TRAEFIK_SUBDOMAIN": "jempi-api",
    "JEMPI_WEB_TRAEFIK_HOST_NAME": "jempi-web",
}
```

### Santempi

Set the following environment variables in the package-metadata.json in the "./client-registry-santempi" directory

```bash
"environmentVariables":
{
# Other Configurations
...
    "SANTEDB_WWW_TRAEFIK_SUBDOMAIN": "santewww",
    "SANTEDB_MPI_TRAEFIK_SUBDOMAIN": "santempi"
}
```

### Enabling Kibana

Set the following environment variables in the package-metadata.json in the "./dashboard-visualiser-kibana" directory

```bash

"environmentVariables":
{
# Other Configurations
...
    "KIBANA_TRAEFIK_SUBDOMAIN": "kibana"
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
    "MINIO_BROWSER_REDIRECT_URL": "https://domain/minio/"
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
    "GF_SERVER_DOMAIN": "domain",
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
    "OPENHIM_SUBDOMAIN": "domain",
    "OPENHIM_CONSOLE_BASE_URL": "http://domain"
    "OPENHIM_CORE_MEDIATOR_HOSTNAME": "domain/openhimcomms",
    "OPENHIM_MEDIATOR_API_PORT": "443"
}
```
