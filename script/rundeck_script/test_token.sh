#!/bin/bash

## asuka用
WEBHOOK_URL="https://hooks.slack.com/services/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"

# get Airbnb token
AIRBNB_TOKEN=$(curl -X POST -d "client_id=3092nxybyb0otqw18e8nh5nty" \
    -d "locale=en-US" \
    -d "currency=USD" \
    -d grant_type=password \
    -d password=xxxxxxxxxx \
    -d username=tokiokichi202@gmail.com https://api.airbnb.com/v1/authorize | sed -e 's/[{}]/''/g' | cut -d , -f 1 | sed 's/.*\://' | sed 's/[^"]*"\([^"]*\)".*/\1/')

echo $AIRBNB_TOKEN

