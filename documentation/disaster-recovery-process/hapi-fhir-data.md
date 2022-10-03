---
description: FHIR messages Backup & Restore.
---

# HAPI FHIR Data

Validated messages from HAPI FHIR will  be stored in PostgreSQL database.

The following content will detail the backup and restore process of this data.

### Backups

> This section assumes Postgres backups are made using `pg_basebackup`

#### Postgres (Hapi-FHIR)

To start up HAPI FHIR and ensure that the backups can be made, ensure that you have created the HAPI FHIR bind mount directory (eg./backup)

### Disaster Recovery

> NB! DO NOT UNTAR OR EDIT THE FILE PERMISSIONS OF THE POSTGRES BACKUP FILE

#### Postgres (HAPI FHIR)

Preliminary steps:

1. Do a `destroy` of `fhir-datastore-hapi-fhir` using the CLI binary (./platform-linux for linux)
2. Make sure the Postgres volumes on nodes other than the swarm leader have been removed as well! You will need to ssh into each server and manually remove them.
3. Do an `init` of `fhir-datastore-hapi-fhir` using the CLI binary

After running the preliminary steps, run the following commands on the node hosting the Postgres leader:

> NOTE: The value of the `REPMGR_PRIMARY_HOST` variable in your .env file indicates the Postgres leader

1. Retrieve the Postgres leader's container-ID using: `docker ps -a`. \
   Hereafter called `postgres_leader_container_id`
2. Run the following command: \
   `docker exec -t <postgres_leader_container_id> pg_ctl stop -D /bitnami/postgresql/data`
3. Wait for the Postgres leader container to die and start up again. \
   You can monitor this using: `docker ps -a`
4. Run the following command: \
   &#x20;`docker rm <postgres_leader_container_id>`
5. Retrieve the new Postgres leader's container-ID using `docker ps -a`, be weary to not use the old `postgres_leader_container_id`
6. Retrieve the Postgres backup file's name as an absolute path (/backups/postgresql\_xxx).\
   Hereafter called `backup_file`
7.  Run the following commands in the order listed :

    ```
    # Stop the server running in the container
    docker exec -t <postgres_leader_container_id> pg_ctl stop -D /bitnami/postgresql/data

    # Clear the contents of /bitnami/postgresql/data
    docker exec -t --user root <postgres_leader_container_id> sh -c 'cd /bitnami/postgresql/data && rm -rf $(ls)'

    # Copy over the base.tar file
    sudo docker cp <backup_file>/base.tar <postgres_leader_container_id>:/bitnami/postgresql

    # Extract the base.tar file
    docker exec -t --user root <postgres_leader_container_id> sh -c 'tar -xf /bitnami/postgresql/base.tar --directory=/bitnami/postgresql/data'

    # Copy over the pg_wal.tar file
    sudo docker cp <backup_file>/pg_wal.tar <postgres_leader_container_id>:/bitnami/postgresql

    # Extract pg_wal.tar
    docker exec -t --user root <postgres_leader_container_id> sh -c 'tar -xf /bitnami/postgresql/pg_wal.tar --directory=/bitnami/postgresql/data/pg_wal'

    # Copy conf dir over
    docker exec -t --user root <postgres_leader_container_id> sh -c 'cp -r /bitnami/postgresql/conf/. /bitnami/postgresql/data'

    # Set pg_wal.tar permissions
    docker exec -t --user root <postgres_leader_container_id> sh -c 'cd /bitnami/postgresql/data/pg_wal && chown -v 1001 $(ls)'

    # Start the server
    docker exec -t <postgres_leader_container_id> pg_ctl start -D /bitnami/postgresql/data
    ```
8. Do a `down` of `fhir-datastore-hapi-fhir` using the CLI binary\
   Example: `./platform-linux down fhir-datastore-hapi-fhir –env-file=.env.*`
9. Wait for the `down` operation to complete
10. Do an `init` of `fhir-datastore-hapi-fhir` using the CLI binary\
    Example: `./platform-linux init fhir-datastore-hapi-fhir –env-file=.env.*`

Postgres should now be recovered

> Note: After performing the data recovery, it is possible to get an error from HAPI FHIR (500 internal server error) while the data is still being replicated across the cluster. Wait a minute and try again.
