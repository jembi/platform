#!/bin/bash

readonly ACTION=$1
readonly MODE=$2

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)
readonly COMPOSE_FILE_PATH

ROOT_PATH="${COMPOSE_FILE_PATH}/.."
readonly ROOT_PATH

. "${ROOT_PATH}/utils/log.sh"

hapiFhirReplicas=${HAPI_FHIR_INSTANCES:-1}
FHIR_IG_URL=${FHIR_IG_URL:-""}

if [ -z "$FHIR_IG_URL" ]; then
  log error "FHIR IG url should be specified using the env variable 'FHIR_IG_URL'"
else
  if [ "$ACTION" == "init" ]; then
    docker stack deploy -c "${COMPOSE_FILE_PATH}"/docker-compose.yml instant

    log info "Sleep 60 seconds to allow the FHIR IG import processs to finish"
    sleep 60

    docker service scale instant_hapi-fhir=0

    log info "Sleep 10 seconds to give HAPI-FHIR time to scale down"
    sleep 10

    docker service scale instant_hapi-fhir="$hapiFhirReplicas"
    docker service rm instant_hapi-fhir-config-importer

    # Sleep to allow the config importer to be removed. This is to enable the removal of the instant volume
    sleep 120
  else
    log error "Valid option is init"
  fi
fi
