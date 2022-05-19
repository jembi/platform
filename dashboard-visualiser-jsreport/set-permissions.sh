#!/bin/bash

if [[ $(basename $(pwd)) != "dashboard-visualiser-jsreport" ]]; then
    echo "Please change your working directory to dashboard-visualiser-jsreport's root directory before running the script. Exiting..."
    exit 1
fi

sudo chmod 777 scripts/

cd ./scripts/ || exit 1
for i in $(find); do
    sudo chmod 777 "$i"
    sudo chown 1000 "$i"
    sudo chgrp 1000 "$i"
done
cd .. || exit 1
echo "Successfully set file permissions"
