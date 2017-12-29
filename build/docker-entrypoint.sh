#!/bin/bash

#
# docker entrypoint - load necessary envrionment variables and/or docker secrets 
# and execute certbot with the provided domain list
#

#
# functions
#

function log {
  # print a log prefix
  echo "$(date +%Y/%m/%d-%H:%M:%S) - docker-entrypoint.sh - $1"
}

function load_secret {
    # function checks if specified environment variable contains the file path to a docker secret
    # if so it overwrite the value with the file contents

    # first parameter is the environment variable name 
    name=${1}
    # second parameter is the value of the environment variable
    value=${2}

    # now check if the value equals a file in the container
    if [ -f "${value}" ]; then
        log "env var ${name} is pointing to file ${value}. overwrite variable with content from file"
        export ${name}=$(cat "${value}")
    fi
}

#
# main
#

log "welcome to the certbot entrypoint"

log "validating environment variables"
# lets get trough all env vars necessary for the process and try to re-load them from docker secrets
# afterwards lets check if all necessary variables are specified
load_secret AWS_DEFAULT_REGION ${AWS_DEFAULT_REGION}
load_secret AWS_ACCESS_KEY_ID ${AWS_ACCESS_KEY_ID}
load_secret AWS_SECRET_ACCESS_KEY ${AWS_SECRET_ACCESS_KEY}
load_secret DOMAIN ${DOMAIN}
load_secret EMAIL ${EMAIL}

[ -z "${AWS_DEFAULT_REGION}" ] && log "AWS_DEFAULT_REGION not specified. set it to eu-central-1" && export AWS_DEFAULT_REGION="eu-central-1"
[ -z "${AWS_ACCESS_KEY_ID}" ] && log "AWS_ACCESS_KEY_ID not specified. aborting" && exit 1
[ -z "${AWS_SECRET_ACCESS_KEY}" ] && log "AWS_SECRET_ACCESS_KEY not specified. aborting" && exit 1
[ -z "${DOMAIN}" ] && log "DOMAIN not specified. aborting" && exit 1
[ -z "${EMAIL}" ] && log "EMAIL not specified. aborting" && exit 1

log "entering infinite loop. executing certbot every 24hours"
while true; do
    log "executing certbot for the domain(s) ${DOMAIN}"
    certbot certonly --non-interactive --manual-public-ip-logging-ok --agree-tos \
        --manual --preferred-challenges=dns --manual-auth-hook /authenticator.sh --manual-cleanup-hook /cleanup.sh \
        -m ${EMAIL} -d ${DOMAIN}

    sleep 86400
done