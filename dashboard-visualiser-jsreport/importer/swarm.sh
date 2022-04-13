#!/bin/bash

Action=$1
Mode=$2

STATEFUL_NODES=${STATEFUL_NODES:-"cluster"}
JS_REPORT_SUB_DOMAIN=${JS_REPORT_SUB_DOMAIN:-"localhost"}
INSECURE=${INSECURE:-"false"}

COMPOSE_FILE_PATH=$(
  cd "$(dirname "${BASH_SOURCE[0]}")" || exit
  pwd -P
)

ROOT_PATH="${COMPOSE_FILE_PATH}/.."
. "${ROOT_PATH}/utils/config-utils.sh"

if [[ "$Mode" == "dev" ]]; then
  JsReportDomainName="${JS_REPORT_SUB_DOMAIN}:5488"
else
  JsReportDomainName="${JS_REPORT_SUB_DOMAIN}.${DOMAIN_NAME}"
fi

if [[ "$INSECURE" == "true" ]]; then
  JsReportUrl="http://${JsReportDomainName}/api/import"
else
  JsReportUrl="https://${JsReportDomainName}/api/import"
fi

VerifyJsrServiceStatus() {
  local startTime=$(date +%s)
  until [[ $(docker service ls -f name=instant_dashboard-visualiser-jsreport --format "{{.Replicas}}") == *"${JS_REPORT_INSTANCES}/${JS_REPORT_INSTANCES}"* ]]; do
    config::timeout_check $startTime "dashboard-visualiser-jsreport to start"
    sleep 1
  done

  local awaitHelperState=$(docker service ps instant_await-helper --format "{{.CurrentState}}")
  until [[ $awaitHelperState == *"Complete"* ]]; do
    config::timeout_check $startTime "dashboard-visualiser-jsreport status check"
    sleep 1

    awaitHelperState=$(docker service ps instant_await-helper --format "{{.CurrentState}}")
    if [[ $awaitHelperState == *"Failed"* ]] || [[ $awaitHelperState == *"Rejected"* ]]; then
      echo "Fatal: Received error when trying to verify state of dashboard-visualiser-jsreport. Error:
       $(docker service ps instant_await-helper --no-trunc --format \"{{.Error}}\")"
      exit 1
    fi
  done

  docker service rm instant_await-helper
}

if [[ "$Action" == "init" ]]; then
  docker stack deploy -c "${COMPOSE_FILE_PATH}"/docker-compose.await-helper.yml instant

  echo "Verifying JS Reports service status"
  VerifyJsrServiceStatus

  ServiceCallResponse=$(curl -u admin:${JS_REPORT:-"dev_password_only"} --location --request POST ${JsReportUrl} \
    --header "Content-Type: multipart/form-data" \
    --form "=@\"$COMPOSE_FILE_PATH/export.jsrexport\"")
  if [[ "$ServiceCallResponse" == *"\"status\":\"0\",\"message\":\"ok\""* ]]; then
    echo "Configs successfully imported"
  else
    echo "Error in loading configs with: $ServiceCallResponse"
    exit 1
  fi
elif [[ "$Action" == "destroy" ]]; then
  docker service rm instant_await-helper
else
  echo "Valid options are: init or destroy"
fi
