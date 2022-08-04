# Job Scheduler Ofelia

Ofelia does not support config.ini files when run in docker mode thus we need to always use docker labels
Ofelia does not support attaching to docker services
Ofelia does not support job-run (which allows you to launch a job with a specified image name) labels on non-ofelia services (ie. you may not specify a job of type job-run within the nginx package as ofelia will not pick it up)
Ofelia only initializes jobs when it stands up and does not listen for new containers with new labels to update it's schedules, thus Ofelia needs to be re-up'd every time a change is made to a job that is configured on another service's label
