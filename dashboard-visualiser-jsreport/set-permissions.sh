#!/bin/bash

if [[ $(basename $(pwd)) != "dashboard-visualiser-jsreport" ]]; then
    echo "Please change your working directory to dashboard-visualiser-jsreport's root directory before running the script. Exiting..."
    exit 1
fi

sudo chmod 777 scripts/

while read -r file; do
    sudo chown 1000 "$file"
    sudo chgrp 1000 "$file"
    sudo chmod 777 "$file"
done < <(find ./scripts)
echo "Successfully set file permissions"
