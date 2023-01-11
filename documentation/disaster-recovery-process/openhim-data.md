---
description: OpenHIM backup & restore
---

# OpenHIM Data

OpenHIM transaction logs and other data is stored in the Mongo database.\
Restoring this data means restoring all the history of transactions which mandatory to recover in case something unexpected happened and we lost all the data.

In the following sections, we will cover:&#x20;

* Already implemented jobs to create backups periodically
* How to restore the backups&#x20;

### Backup & Restore

#### Single node

[Single node restore docs](https://www.mongodb.com/docs/v4.2/tutorial/backup-and-restore-tools/)

The following job may be used to set up a backup job for a single node Mongo:

```ini
[job-run "mongo-backup"]
schedule= @every 24h
image= mongo:4.2
network= mongo_backup
volume= /backups:/tmp/backups
command= sh -c 'mongodump --uri=${OPENHIM_MONGO_URL} --gzip --archive=/tmp/backups/mongodump_$(date +%s).gz'
delete= true
```

#### Cluster

[Cluster restore docs](https://www.mongodb.com/docs/v4.2/tutorial/restore-replica-set-from-backup/)

The following job may be used to set up a backup job for clustered Mongo:

```ini
[job-run "mongo-backup"]
schedule= @every 24h
image= mongo:4.2
network= mongo_backup
volume= /backups:/tmp/backups
command= sh -c 'mongodump --uri=${OPENHIM_MONGO_URL} --gzip --archive=/tmp/backups/mongodump_$(date +%s).gz'
delete= true
```

#### Restore

In order to restore from a backup you would need to launch a Mongo container with access to the backup file and the mongo\_backup network by running the following command:

`docker run -d --network=mongo_backup --mount type=bind,source=/backups,target=/backups mongo:4.2`

Then exec into the container and run mongorestore:

`mongorestore --uri="mongodb://mongo-01:27017,mongo-02:27017,mongo-03:27017/openhim?replicaSet=mongo-set" --gzip --archive=/backups/<NAME_OF_BACKUP_FILE>`

The data should be restored.
