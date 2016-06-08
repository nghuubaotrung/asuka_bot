#!/bin/bash

NAME="asuka"
PUBLISH_CHANNEL="#release"
TEST_CHANNEL="test"

## asuka用
WEBHOOK_URL=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

CHECK_MONTH="$(date -v+4m +'%m')"
CHECK_YEAR="$(date -v+4m +'%Y')"

LAST_DAY="$(cal $CHECK_MONTH $CHECK_YEAR | egrep -e '^ [0-9]|^[0-9]' | tr '\n' ' ' | awk '{print $NF}')"

FIRST_DATE=$CHECK_YEAR-$CHECK_MONTH-01
LAST_DATE=$CHECK_YEAR-$CHECK_MONTH-$LAST_DAY

echo $FIRST_DATE
echo $LAST_DATE

# get Airbnb token
AIRBNB_TOKEN=$(curl -X POST -d "client_id=3092nxybyb0otqw18e8nh5nty" \
    -d "locale=en-US" \
    -d "currency=USD" \
    -d grant_type=password \
    -d password=xxxxxxxxxxxxxxxxxxxx \
    -d username=tokiokichi202@gmail.com https://api.airbnb.com/v1/authorize | sed -e 's/[{}]/''/g' | cut -d , -f 1 | sed 's/.*\://' | sed 's/[^"]*"\([^"]*\)".*/\1/')

echo $AIRBNB_TOKEN


RESPONSE=200

#本番
FULL_HOUSE="11398837"
CONY="11033998"
BROWN="11574448"

HOUSE_LIST=($FULL_HOUSE $CONY $BROWN)

#sandbox用
#HOUSE_LIST=("7447209")

for house in "${HOUSE_LIST[@]}"
do
    echo $house

    # update Calendar
    RESPONSE=$(curl -i -X PUT --compressed -H "X-Airbnb-OAuth-Token: $AIRBNB_TOKEN" \
        -H "Content-Type: application/json; charset=UTF-8" \
        --data-binary '{"availability":"unavailable"}' \
        https://api.airbnb.com/v2/calendars/$house/$FIRST_DATE/$LAST_DATE \
        2>/dev/null | head -n 1 | cut -d$' ' -f2)
done

echo $RESPONSE

##### 通知
publish_data=`cat << EOF
    payload={
        "channel": "$PUBLISH_CHANNEL",
        "username": "$NAME",
        "link_names": 1,
        "attachments": [{
            "color": "#FACC2E",
            "title": "RELEASE REPORT @here" ,
            "text": "各リストを更新しました。更新内容は以下の通りです。\n\n Blocked: $CHECK_YEAR-$CHECK_MONTH \n\n Request Response Code: $RESPONSE \n\n 以上です。Binさん、Junさん、ご確認宜しくお願い致します。\n\n\n https://www.airbnb.com/rooms"
        }]
    }
EOF`

## 通知送る
curl -X POST --data-urlencode "$publish_data" $WEBHOOK_URL

if [ $RESPONSE -ne 200 ]; then
    exit 1;
fi
