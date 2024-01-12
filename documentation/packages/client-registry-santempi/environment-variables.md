---
description: Listed in this page are all environment variables needed to run Kibana.
---

# Environment Variables

<table><thead><tr><th width="244">Variable Name</th><th width="96">Type</th><th width="171">Relevance</th><th width="103">Required</th><th>Default</th></tr></thead><tbody><tr><td>SANTEMPI_INSTANCES</td><td>Number</td><td>Number of service replicas </td><td>No</td><td>1</td></tr><tr><td>SANTEMPI_MAIN_CONNECTION_STRING</td><td>String</td><td>Connection string to SanteMPI</td><td>No</td><td><em>Check below table</em></td></tr><tr><td>SANTEMPI_AUDIT_CONNECTION_STRING</td><td>String</td><td>Audit connection string to SanteMPI</td><td>No</td><td><em>Check below table</em></td></tr><tr><td>SANTEMPI_POSTGRESQL_PASSWORD</td><td>String</td><td>SanteMPI postgreSQL password</td><td>No</td><td>SanteDB123</td></tr><tr><td>SANTEMPI_POSTGRESQL_USERNAME</td><td>String</td><td>SanteMPI postgreSQL username</td><td>No</td><td>santempi</td></tr><tr><td>SANTEMPI_REPMGR_PRIMARY_HOST</td><td>String</td><td>SanteMPI postgreSQL replicas manager primary host</td><td>No</td><td>santempi-psql-1</td></tr><tr><td>SANTEMPI_REPMGR_PARTNER_NODES</td><td>String</td><td>SanteMPI postgreSQL replicas manager nodes hosts</td><td>Yes</td><td>santempi-psql-1,santempi-psql-2,santempi-psql-</td></tr></tbody></table>

### Note

The environment variable `SANTEMPI_REPMGR_PARTNER_NODES` will differ from cluster and single mode.

Default value for `SANTEMPI_MAIN_CONNECTION_STRING`:&#x20;

```
server=santempi-psql-1;port=5432; database=santedb; user id=santedb; password=SanteDB123; pooling=true; MinPoolSize=5; MaxPoolSize=15; Timeout=60;
```

Default value for `SANTEMPI_AUDIT_CONNECTION_STRING`:&#x20;

```
server=santempi-psql-1;port=5432; database=auditdb; user id=santedb; password=SanteDB123; pooling=true; MinPoolSize=5; MaxPoolSize=15; Timeout=60;
```
