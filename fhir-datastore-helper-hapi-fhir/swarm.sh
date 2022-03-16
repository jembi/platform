#!/bin/bash

hapiFhirReplicas=${HAPI_FHIR_INSTANCES:-1}
fhirIgUrl=${FHIR_IG_URL}

composeFilePath=$(
  cd "$(dirname "${BASH_SOURCE[0]}")"
  pwd -P
)

if [ -z "$fhirIgUrl" ]; then
  echo "FHIR IG url should be specified using the env variable 'FHIR_IG_URL'"
else
  if [ "$1" == "init" ]; then
    docker stack deploy -c "$composeFilePath"/docker-compose.yml instant

    echo "Sleep 60 seconds to allow the FHIR IG import processs to finish"
    sleep 60

    docker service scale instant_hapi-fhir=0

    echo "Sleep 10 seconds to give HAPI-FHIR time to scale down"
    sleep 10

    docker service scale instant_hapi-fhir=$hapiFhirReplicas
    docker service rm instant_hapi-fhir-config-importer

    # Sleep to allow the config importer to be removed. This is to enable the removal of the instant volume
    sleep 120
  else
    echo "Valid option is init"
  fi
fi
