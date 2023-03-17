---
description: A job scheduling tool.
---

# Local Development

## Ofelia - Job Scheduler&#x20;

[Job Docs](https://github.com/mcuadros/ofelia/blob/master/docs/jobs.md)

The platform uses image: mcuadros/ofelia:v0.3.6 which has the following limitations:

* Ofelia does not support config.ini files when run in docker mode (which enables scheduling jobs with docker labels) thus we need to always use the config.ini file for creating jobs.
* Ofelia does not support attaching to a running instance of a service.
* Ofelia does not support job-run (which allows you to launch a job with a specified image name) labels on non-ofelia services (ie. you may not specify a job of type job-run within the nginx package as ofelia will not pick it up)&#x20;
* Ofelia only initializes jobs when it stands up and does not listen for new containers with new labels to update it's schedules, thus Ofelia needs to be re-up'd every time a change is made to a job that is configured on another service's label.

## Example of a job config

An example of job config in the file `config.example.ini` existing in the folder `<path to project packages>/job-scheduler-ofelia/.`

```
[job-run "renew-certs"]
schedule = @every 1440h ;60 days
image = jembi/swarm-nginx-renewal:v1.0.0
volume = renew-certbot-conf:/instant
volume = /var/run/docker.sock:/var/run/docker.sock:ro
environment = RENEWAL_EMAIL=${RENEWAL_EMAIL}
environment = STAGING=${STAGING}
environment = DOMAIN_NAME=${DOMAIN_NAME}
environment = SUBDOMAINS=${SUBDOMAINS}
environment = STACK_NAME=${STACK_NAME}
delete = true
```

{% hint style="info" %}
You can specify multiple jobs in a single file.
{% endhint %}
