#!/bin/bash

NAME="asuka"
PUBLISH_CHANNEL="#monitor"
TEST_CHANNEL="test"

## asuka用
WEBHOOK_URL=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

MEMORY_REPORT=$(top -l 1 -s 0 | grep PhysMem | sed 's/, /         /g')

##### 通知
publish_data=`cat << EOF
    payload={
        "channel": "$PUBLISH_CHANNEL",
        "username": "$NAME",
        "link_names": 1,
        "attachments": [{
            "color": "#FACC2E",
            "title": "Rundeck Server Monitoring" ,
            "text": "Testing Server in Sleep Mode \n\n $MEMORY_REPORT"
        }]
    }
EOF`

## 通知送る
curl -X POST --data-urlencode "$publish_data" $WEBHOOK_URL
