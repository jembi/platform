
# Interoperability Layer - OpenHIM

The Interoperability Layer is the base of the Platform architecture.

This component consists of two services:

* Interoperability Layer - [OpenHIM](http://openhim.org/)

## Accessing the services

### OpenHIM

* Console: <http://localhost:9000>
* Username: **root@openhim.org**
* Password: **instant101**

## Testing the Interoperability Component

As part of the Interoperability Layer setup we also do some initial config import for connecting the services together.

* OpenHIM: Import a channel configuration that routes requests to the Data Store - HAPI FHIR service

## Backup restore

### Single node

[Single node restore docs](https://www.mongodb.com/docs/v4.2/tutorial/backup-and-restore-tools/)

The following job may be used to set up a backup job for a single node mongo

```ini
[job-run "mongo-backup"]
schedule= @every 24h
image= mongo:4.2
network= mongo_backup
volume= /backups:/tmp/backups
command= sh -c 'mongodump --uri=${OPENHIM_MONGO_URL} --gzip --archive=/tmp/backups/mongodump_$(date +%s).gz'
delete= true
```

### Cluster

[Cluster restore docs](https://www.mongodb.com/docs/v4.2/tutorial/restore-replica-set-from-backup/)

The following job may be used to set up a backup job for clustered mongo

```ini
[job-run "mongo-backup"]
schedule= @every 24h
image= mongo:4.2
network= mongo_backup
volume= /backups:/tmp/backups
command= sh -c 'mongodump --uri=${OPENHIM_MONGO_URL} --gzip --archive=/tmp/backups/mongodump_$(date +%s).gz'
delete= true
```

### Restore

In order to restore from a backup you would need to launch a mongo container with access to the backup file and the mongo_backup network:

`docker run -d --network=mongo_backup --mount type=bind,source=/backups,target=/backups mongo:4.2`

Then exec into the container and run mongorestore:

`mongorestore --uri="mongodb://mongo-1:27017,mongo-2:27017,mongo-3:27017/openhim?replicaSet=mongo-set" --gzip --archive=/backups/<NAME_OF_BACKUP_FILE>`
