#!/bin/bash

#
# create a dns entry in route 53 for domain authentication
# 

function log {
  # print a log prefix
  echo "$(date +%Y/%m/%d-%H:%M:%S) - authenticator.sh - $1"
}

#
# main
#

log "script started"
log "CERTBOT_DOMAIN: ${CERTBOT_DOMAIN}"
log "CERTBOT_VALIDATION: ${CERTBOT_VALIDATION}"

log "retrive zone id from domain"
domainbase=$(expr match "$CERTBOT_DOMAIN" '.*\.\(.*\..*\)')
zoneid=$(aws route53 list-hosted-zones | jq ".HostedZones[] | select(.Name==\"${domainbase}.\") | .Id" -r)
zoneid=$(basename ${zoneid})
log "found zone id: $zoneid"

log "prepare aws route53 change request"
cat > /tmp/change-request.json << EOF
{
    "Comment": "Update record to reflect new IP address of home router",
    "Changes": [
        {
            "Action": "CREATE",
            "ResourceRecordSet": {
                "Name": "_acme-challenge.${CERTBOT_DOMAIN}",
                "Type": "TXT",
                "TTL": 60,
                "ResourceRecords": [
                    {
                        "Value": "\"${CERTBOT_VALIDATION}\""
                    }
                ]
            }
        }
    ]
}
EOF

log "send change request to aws"
changeid=$(aws route53 change-resource-record-sets --hosted-zone-id ${zoneid} --change-batch file:///tmp/change-request.json | jq -r .ChangeInfo.Id)
changeid=$(basename ${changeid})
log "received change id ${changeid}"

log "waiting for change to be INSYNC"
while [ "$(aws route53 get-change --id ${changeid} | jq -r .ChangeInfo.Status)" != "INSYNC" ]; do
    sleep 3
done
log "dns changes are in sync"

log "wait a little while for dns changes to propagate"
sleep 15
log "script ended"