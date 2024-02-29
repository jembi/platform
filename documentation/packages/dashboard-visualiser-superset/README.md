---
description: >-
  Superset is a visualisation tool meant for querying data from a SQL-type
  database.
---

# Dashboard Visualiser - Superset

## Version upgrade process (with rollback capability)
By default if you simply update the image that the superset service uses to a later version, when the container is scheduled it will automatically run a database migration and the version of superset will be upgraded. The problem, however, is that if there is an issue with this newer version you cannot rollback the upgrade since the database migration that ran will cause the older version to throw an error and the container will no longer start.
As such it is recommended to first create a postgres dump of the superset postgres database before attempting to upgrade superset's version.
1. Exec into the postgres container as the root user (otherwise you will get write permission issues)
```bash
docker exec -u root -it superset_postgres-metastore-1.container-id-here bash
```
2. Run the pg_dump command on the superset database. The database name is stored in `SUPERSET_POSTGRESQL_DATABASE` and defaults to `superset`
```bash
pg_dump superset -c -U admin > superset_backup.sql
```
3. Copy that dumpped sql script outside the container
```bash
docker cp superset_postgres-metastore-1.container-id-here:/superset_backup.sql /path/to/save/to/superset_backup.sql
```
4. Update the superset version (either through a platform deploy or with a docker command on the server directly -- `docker service update superset_dashboard-visualiser-superset --image apache/superset:tag`)

### Rolling back upgrade
In the event that something goes wrong you'll need to rollback the database changes too, i.e.: run the superset_backup.sql script we created before upgrading the superset version
1. Copy the superset_backup.sql script into the container
```bash
docker cp /path/to/save/to/superset_backup.sql superset_postgres-metastore-1.container-id-here:/superset_backup.sql 
```
2. Exec into the postgres container
```bash
docker exec -it superset_postgres-metastore-1.container-id-here bash
```
3. Run the sql script (where -d superset is the database name stored in `SUPERSET_POSTGRESQL_DATABASE`)
```bash
cat superset_backup.sql | psql -U admin -d superset
```
