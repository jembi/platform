#!/bin/bash

# This script is here to set and reset the file permissions that might have been altered when running
# JS Report with the dev mount attached. Make sure that you run this script before and after running JS Report
# with the dev mount attached.

if [[ $(basename $(pwd)) != "dashboard-visualiser-jsreport" ]]; then
    echo "Please change your working directory to dashboard-visualiser-jsreport's root directory before running the script. Exiting..."
    exit 1
fi

sudo chmod 777 data/

while read -r file; do
    sudo chown 1000 "$file"
    sudo chgrp 1000 "$file"
    sudo chmod 777 "$file"
done < <(find ./data)
echo "Successfully set file permissions"
