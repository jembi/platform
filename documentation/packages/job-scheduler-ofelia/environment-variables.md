---
description: Listed in this page are all environment variables needed to run Ofelia.
---

# Environment Variables

The Ofelia service does not make use of any environment variables. However, when specifying jobs in the `config.ini` file(s) we can pass any environment variable in.&#x20;

Example:&#x20;

```
[job-run "mongo-backup"]
schedule= @daily
image= mongo:4.2
network= mongo_backup
volume= /backups:/tmp/backups
command= sh -c 'mongodump --uri=${OPENHIM_MONGO_URL} --gzip --archive=/tmp/backups/mongodump_$(date +%s).gz'
delete= true
```

{% hint style="info" %}
In the example above, `OPENHIM_MONGO_URL` is an environment variable.
{% endhint %}
