#!/bin/bash
# - $1 : Stack name that the services are grouped under
STACK_NAME="${1:-"instant"}"

COMPOSE_FILE_PATH=$(
    cd "$(dirname "${BASH_SOURCE[0]}")" || exit
    pwd -P
)

ROOT_PATH="${COMPOSE_FILE_PATH}/.."
. "${ROOT_PATH}/utils/config-utils.sh"
. "${ROOT_PATH}/utils/log.sh"

log info 'Initiating the mongo replica set'

MONGO_SET_COUNT=${MONGO_SET_COUNT:-3}
config='{"_id":"mongo-set","members":['
priority="1"
for i in $(seq 1 "$MONGO_SET_COUNT"); do
    config=$(printf '%s{"_id":%s,"priority":%s,"host":"mongo-%s:27017"}' "$config" $((i - 1)) $priority "$i")
    if [[ $i != $MONGO_SET_COUNT ]]; then
        config=$(printf '%s,' "$config")
    fi
    priority="0.5"
done
config=$(printf '%s]}' "$config")

log info 'Waiting to ensure all the mongo instances for the replica set are up and running'
running_instance_count=0
start_time=$(date +%s)
until [[ $running_instance_count -eq $MONGO_SET_COUNT ]]; do
    config::timeout_check "$start_time" "mongo replica set to run"
    sleep 1

    running_instance_count=0
    for i in $(docker service ls -f name=${STACK_NAME}_mongo --format "{{.Replicas}}"); do
        if [[ $i = "1/1" ]]; then
            running_instance_count=$((running_instance_count + 1))
        fi
    done
done

# Ensures that the replica sets are reachable
reachable_instance_count=1
until [[ $reachable_instance_count -eq $((MONGO_SET_COUNT + 1)) ]]; do
    config::await_service_reachable "mongo-$reachable_instance_count" $STACK_NAME "waiting for connections on port"
    reachable_instance_count=$((reachable_instance_count + 1))
done

# TODO (PLAT-256): only works if deploying to node-1 labeled node
# With docker swarm any manager can be the target but this bit of code only work if we target node-1 specifically.
# Which is generally what we do, but if node-1 is down or we choose to target another node this won't work.
container_name=""
if [[ "$(docker ps -f name=${STACK_NAME}_mongo-1 --format "{{.ID}}")" ]]; then
    container_name="$(docker ps -f name=${STACK_NAME}_mongo-1 --format "{{.ID}}")"
fi

initiate_rep_set_response=$(docker exec -i "$container_name" mongo --eval "rs.initiate($config)")
if [[ $initiate_rep_set_response == *"{ \"ok\" : 1 }"* ]] || [[ $initiate_rep_set_response == *"already initialized"* ]]; then
    log info "Replica set successfully set up"
else
    log error "Fatal: Unable to set up replica set"
    exit 1
fi
