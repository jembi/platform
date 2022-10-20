# Running in Clustered Mode

## Pre-Deploy Configuration

If running in clustered mode, take note that each machine has to have the following vm.max\_map\_count setting:

`sysctl -w vm.max_map_count=262144`
