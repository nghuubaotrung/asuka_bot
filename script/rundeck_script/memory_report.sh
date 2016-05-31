#!/bin/bash

NAME="asuka"
PUBLISH_CHANNEL="#monitor"

### test
#PUBLISH_CHANNEL="#test"

WEBHOOK_URL=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

MEMORY_REPORT=$(top -l 1 -s 0 | grep PhysMem | sed 's/, /         /g')
SLEEP_STATUS=$(sudo systemsetup -getcomputersleep)

##### 通知
publish_data=`cat << EOF
    payload={
        "channel": "$PUBLISH_CHANNEL",
        "username": "$NAME",
        "link_names": 1,
        "attachments": [{
            "color": "#FACC2E",
            "title": "Asuka's Rundeck Server Monitoring" ,
            "text": "1. Memory Check: \n\n  - $MEMORY_REPORT \n\n 2. Idle Status: \n\n - $SLEEP_STATUS"
        }]
    }
EOF`

## 通知送る
curl -X POST --data-urlencode "$publish_data" $WEBHOOK_URL
