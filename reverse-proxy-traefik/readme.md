# Reverse Proxy Traefik

## Domain Based Reverse Proxy

### Superset

Set the following environment variables in the package-metadata.json in the "" directory

```bash
"environmentVariables": 
{
# Other Configurations
...
    
}
```

### Jempi

Set the following environment variables in the package-metadata.json in the "" directory

```bash
"environmentVariables": 
{
# Other Configurations
...
    
}
```

### Santempi

Set the following environment variables in the package-metadata.json in the "" directory

```bash
"environmentVariables": 
{
# Other Configurations
...
    
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
    "MINIO_BROWSER_REDIRECT_URL": "http://health.org/minio"
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
    "GF_SERVER_DOMAIN": "heath.org",
}

```

### JS Report

Set the following environment variables in the package-metadata.json in the "dashboard-visualiser-jsreport" directory

```bash
"environmentVariables": 
{
# Other Configurations
...
    
}
```

### OpenHIM

Set the following environment variables in the package-metadata.json in the "interoperability-layer-openhim" directory

```bash
"environmentVariables": 
{
# Other Configurations
...
    
}
```
