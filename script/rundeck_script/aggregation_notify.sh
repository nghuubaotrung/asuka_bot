#!/bin/bash

NAME="asuka"
PUBLISH_CHANNEL="#test"
TEST_CHANNEL="test"

## asuka用
WEBHOOK_URL="https://hooks.slack.com/services/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"

publish_data=`cat << EOF
    payload={
        "channel": "$PUBLISH_CHANNEL",
        "username": "$NAME",
        "text": "Binさん、集計終わりましたので、ご確認よろしくお願い致します！"
    }
EOF`

###集計ロジック

curl -X POST --data-urlencode "$publish_data" $WEBHOOK_URL

