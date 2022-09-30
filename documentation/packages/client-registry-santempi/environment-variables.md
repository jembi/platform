---
description: Listed in this page are all environment variables needed to run Kibana.
---

# Environment Variables

| Variable Name                       | Type   | Relevance                                         | Required | Default                                        |
| ----------------------------------- | ------ | ------------------------------------------------- | -------- | ---------------------------------------------- |
| SANTEMPI\_INSTANCES                 | Number | Number of service replicas                        | No       | 1                                              |
| SANTEMPI\_MAIN\_CONNECTION\_STRING  | String | Connection string to SanteMPI                     | No       | _Check below table_                            |
| SANTEMPI\_AUDIT\_CONNECTION\_STRING | String | Audit connection string to SanteMPI               | No       | _Check below table_                            |
| SANTEMPI\_POSTGRESQL\_PASSWORD      | String | SanteMPI postgreSQL password                      | No       | SanteDB123                                     |
| SANTEMPI\_POSTGRESQL\_USERNAME      | String | SanteMPI postgreSQL username                      | No       | santempi                                       |
| SANTEMPI\_REPMGR\_PRIMARY\_HOST     | String | SanteMPI postgreSQL replicas manager primary host | No       | santempi-psql-1                                |
| SANTEMPI\_REPMGR\_PARTNER\_NODES    | String | SanteMPI postgreSQL replicas manager nodes hosts  | Yes      | santempi-psql-1,santempi-psql-2,santempi-psql- |

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
