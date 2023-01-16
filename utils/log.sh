#!/bin/bash

set -uo pipefail

# Global constants
PREV_LINE="\e[1A" # moves cursor to previous line
CLEAR_LINE="\e[K" # clears the current line the cursor is on
CLEAR_PREV_LINE="${PREV_LINE}${PREV_LINE}${CLEAR_LINE}"

# Defaults
DEBUG="${DEBUG:-0}"
BASHLOG_FILE="${BASHLOG_FILE:-0}"

root_log_file_path="/tmp/logs"
LOG_FILE_PATH="${root_log_file_path}/${BASHLOG_FILE_PATH:-platform.log}"

function _log_exception() {
    (
        BASHLOG_FILE=0
        BASHLOG_JSON=0
        BASHLOG_SYSLOG=0

        log 'error' "Logging Exception: ${@}"
    )
}

function log() {
    local date_format="${BASHLOG_DATE_FORMAT:-+%F %T}"
    local date="$(date "${date_format}")"
    local date_s="$(date "+%s")"

    local file="${BASHLOG_FILE:-0}"
    local file_path="${LOG_FILE_PATH:-/tmp/$(basename "${0}").log}"

    local json="${BASHLOG_JSON:-0}"
    local json_path="${BASHLOG_JSON_PATH:-/tmp/$(basename "${0}").log.json}"

    local syslog="${BASHLOG_SYSLOG:-0}"
    local tag="${BASHLOG_SYSLOG_TAG:-$(basename "${0}")}"
    local facility="${BASHLOG_SYSLOG_FACILITY:-local0}"
    local pid="${$}"

    local level="${1}"
    local upper="$(echo "${level}" | awk '{print toupper($0)}')"
    local debug_level="${DEBUG:-0}"

    shift 1

    local line="${@}"

    # RFC 5424
    #
    # Numerical         Severity
    #   Code
    #
    #    0       Emergency: system is unusable
    #    1       Alert: action must be taken immediately
    #    2       Critical: critical conditions
    #    3       Error: error conditions
    #    4       Warning: warning conditions
    #    5       Notice: normal but significant condition
    #    6       Informational: informational messages
    #    7       Debug: debug-level messages

    local -A severities
    severities['DEBUG']=7
    severities['INFO']=6
    severities['NOTICE']=5 # Unused
    severities['WARN']=4
    severities['ERROR']=3
    severities['CRIT']=2  # Unused
    severities['ALERT']=1 # Unused
    severities['EMERG']=0 # Unused

    local severity="${severities[${upper}]:-3}"

    if [ "${debug_level}" -gt 0 ] || [ "${severity}" -lt 7 ]; then

        if [ "${syslog}" -eq 1 ]; then
            local syslog_line="${upper}: ${line}"

            logger \
                --id="${pid}" \
                -t "${tag}" \
                -p "${facility}.${severity}" \
                "${syslog_line}" ||
                _log_exception "logger --id=\"${pid}\" -t \"${tag}\" -p \"${facility}.${severity}\" \"${syslog_line}\""
        fi

        if [ "${file}" -eq 1 ]; then
            clean_line="${line//\\e[1A/}"
            clean_line="${clean_line//\\e[K/}"
            local file_line="${date} [${upper}] ${clean_line}"
            echo -e "${file_line}" >>"${file_path}" ||
                _log_exception "echo -e \"${file_line}\" >> \"${file_path}\""
        fi

        if [ "${json}" -eq 1 ]; then
            local json_line="$(printf '{"timestamp":"%s","level":"%s","message":"%s"}' "${date_s}" "${level}" "${line}")"
            echo -e "${json_line}" >>"${json_path}" ||
                _log_exception "echo -e \"${json_line}\" >> \"${json_path}\""
        fi

    fi

    local -A colours
    colours['DEBUG']='\033[34m'  # Blue
    colours['INFO']='\033[32m'   # Green
    colours['NOTICE']=''         # Unused
    colours['WARN']='\033[33m'   # Yellow
    colours['ERROR']='\033[31m'  # Red
    colours['CRIT']=''           # Unused
    colours['ALERT']=''          # Unused
    colours['EMERG']=''          # Unused
    colours['DEFAULT']='\033[0m' # Default

    local -A emoticons
    emoticons['DEBUG']='🔷'
    emoticons['INFO']='❕'
    emoticons['NOTICE']='💡'
    emoticons['WARN']='🔶'
    emoticons['ERROR']='❌'
    emoticons['CRIT']='⛔'
    emoticons['ALERT']='❗❗'
    emoticons['EMERG']='🚨'
    emoticons['DEFAULT']=''

    local norm="${colours['DEFAULT']}"
    local colour="${colours[${upper}]:-\033[31m}"

    if [[ "${line}" == *"${CLEAR_PREV_LINE}"* ]]; then
        # Append package name dynamically when override
        line="${CLEAR_PREV_LINE}[$(dirname -- "$0" | sed -e 's/-/ /g' -e 's/\b\(.\)/\u\1/g')] ${line#*"$CLEAR_PREV_LINE"}"
    else
        line="[$(dirname -- "$0" | sed -e 's/-/ /g' -e 's/\b\(.\)/\u\1/g')] ${line}"
    fi

    local std_line="${colour} ${emoticons[${upper}]} ${line}${norm}"

    # Standard Output (Pretty)
    case "${level}" in
    'default' | 'info' | 'warn')
        echo -e "${std_line}"
        ;;
    'debug')
        if [ "${debug_level}" -gt 0 ]; then
            echo -e "${std_line}"
        fi
        ;;
    'error')
        echo -e "${std_line}" >&2
        ;;
    *)
        log 'error' "Undefined log level trying to log: ${@}"
        ;;
    esac
}

# This is an option if you want to log every single command executed,
# but it will significantly impact script performance and unit tests will fail
if [[ $DEBUG -eq 1 ]]; then
    declare -g prev_cmd="null"
    declare -g this_cmd="null"

    trap 'prev_cmd=$this_cmd; this_cmd=$BASH_COMMAND; log debug $this_cmd' DEBUG
fi

# A function that will return a message called when of parameter not provided
#
# Arguments:
# - $1 : optional - function name missing the parameter
# - $2 : optional - name of the parameter missing
missing_param() {
    local FUNC_NAME=${1:-""}
    local ARG_NAME=${2:-""}

    echo "FATAL: ${FUNC_NAME} parameter ${ARG_NAME} not provided"
}

# Overwrites the last echo'd command with what is provided
#
# Arguments:
# - $1 : message (eg. "Setting passwords... Done")
overwrite() {
    local -r MESSAGE=${1:?$(missing_param "overwrite")}
    if [ "${DEBUG}" -eq 1 ]; then
        log info "${MESSAGE}"
    else
        log info "${CLEAR_PREV_LINE}${MESSAGE}"
    fi
}

# Execute a command handle logging of the output
#
# Arguments:
# - $1 : command (eg. "docker service rm elastic-search")
# - $2 : throw or catch (eg. "throw", "catch")
# - $3 : error message (eg. "Failed to remove elastic-search service")
try() {
    local -r COMMAND=${1:?$(missing_param "try" "COMMAND")}
    local -r SHOULD_THROW=${2:-"throw"}
    local -r ERROR_MESSAGE=${3:?$(missing_param "try" "ERROR_MESSAGE")}

    if [ "${BASHLOG_FILE}" -eq 1 ]; then
        if ! eval "$COMMAND" >>"$LOG_FILE_PATH" 2>&1; then
            log error "$ERROR_MESSAGE"
            if [[ "$SHOULD_THROW" == "throw" ]]; then
                exit 1
            fi
        fi
    else
        if [ "${DEBUG}" -eq 1 ]; then
            if ! eval "$COMMAND"; then
                log error "$ERROR_MESSAGE"
                if [[ "$SHOULD_THROW" == "throw" ]]; then
                    exit 1
                fi
            fi
        else
            if ! eval "$COMMAND" 1>/dev/null; then
                log error "$ERROR_MESSAGE"
                if [[ "$SHOULD_THROW" == "throw" ]]; then
                    exit 1
                fi
            fi
        fi
    fi
}
