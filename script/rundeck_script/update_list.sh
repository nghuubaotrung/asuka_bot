#!/bin/bash

NAME="asuka"
PUBLISH_CHANNEL="#release"
TEST_CHANNEL="test"

## asuka用
WEBHOOK_URL="https://hooks.slack.com/services/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"

## asuka-monitor WebHook : https://hooks.slack.com/services/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

## 日付取得
CHECK_DATE="$(date -v+4m +'%Y-%m-%d')"
CHECK_DAY="$(date -v+4m +'%d')"
DAY_BEFORE="$(date -v+4m -v-1d +'%Y-%m-%d')"

# get Airbnb token
AIRBNB_TOKEN=$(curl -X POST -d "client_id=3092nxybyb0otqw18e8nh5nty" \
    -d "locale=en-US" \
    -d "currency=USD" \
    -d grant_type=password \
    -d password=Takadanobaba202 \
    -d username=tokiokichi202@gmail.com https://api.airbnb.com/v1/authorize | sed -e 's/[{}]/''/g' | cut -d , -f 1 | sed 's/.*\://' | sed 's/[^"]*"\([^"]*\)".*/\1/')

echo $AIRBNB_TOKEN
CHECK_DATE="$(date -v+4m +'%Y-%m-%d')"
CHECK_DAY="$(date -v+4m +'%d')"
DAY_BEFORE="$(date -v+4m -v-1d +'%Y-%m-%d')"

#本番
HOUSE_LIST=("11398837" "11033998" "11574448")

#sandbox用
#HOUSE_LIST=("7447209")


echo $AIRBNB_TOKEN

for house in "${HOUSE_LIST[@]}"
do
    echo $AIRBNB_TOKEN
    echo $house

    # update Calendar
    # block The Day Before
    curl -i -X PUT --compressed -H "X-Airbnb-OAuth-Token: $AIRBNB_TOKEN" \
        -H "Content-Type: application/json; charset=UTF-8" \
        --data-binary '{"availability":"unavailable"}' \
        https://api.airbnb.com/v2/calendars/$house/$DAY_BEFORE/$DAY_BEFORE

    # open Check Day
    curl -i -X PUT --compressed -H "X-Airbnb-OAuth-Token: $AIRBNB_TOKEN" \
        -H "Content-Type: application/json; charset=UTF-8" \
        --data-binary '{"availability":"available"}' \
        https://api.airbnb.com/v2/calendars/$house/$CHECK_DATE/$CHECK_DATE

    # update Get Around
    if [[ $(($CHECK_DAY % 2)) -eq 0 ]]; then
        curl -i -X POST --compressed -H "X-Airbnb-OAuth-Token: $AIRBNB_TOKEN" \
            -H "Content-Type: application/json; charset=UTF-8" \
            --data-binary '{"listing":{"transit":"4 minutes train ride to Shinjuku station. (direct) \n4 minutes train ride to Ikebukuro station. (direct) \n9 minutes train ride to Harajuku station. (direct) \n11 minutes train ride to Shibuya station. (direct)"}}' \
            https://api.airbnb.com/v1/listings/$house/update?client_id=3092nxybyb0otqw18e8nh5nty&locale=en-US&currency=USD
    else
        curl -i -X POST --compressed -H "X-Airbnb-OAuth-Token: $AIRBNB_TOKEN" \
            -H "Content-Type: application/json; charset=UTF-8" \
            --data-binary '{"listing":{"transit":"4 minutes train ride to Shinjuku station. (Direct) \n4 minutes train ride to Ikebukuro station. (Direct) \n9 minutes train ride to Harajuku station. (Direct) \n11 minutes train ride to Shibuya station. (Direct)"}}' \
            https://api.airbnb.com/v1/listings/$house/update?client_id=3092nxybyb0otqw18e8nh5nty&locale=en-US&currency=USD
    fi

    # add Photo
    #    curl -i -X POST --compressed -H "X-Airbnb-OAuth-Token: $AIRBNB_TOKEN" \
        #                -H "Content-Type: multipart/form-data; boundary=d27a2537-d9c1-40e4-b1f9-209eb38d45ff" \
        #                -F name="photos[]" \
        #                -F filename="~/Source-code/asuka_bot/script/rundeck_script/test_profile.png" \
        #                https://api.airbnb.com/v1/listings/$house/update?client_id=3092nxybyb0otqw18e8nh5nty&locale=en-US&currency=USD
done


##### 通知
publish_data=`cat << EOF
    payload={
        "channel": "$PUBLISH_CHANNEL",
        "username": "$NAME",
        "link_names": 1,
        "attachments": [{
            "color": "#FACC2E",
            "title": "RELEASE REPORT @here" ,
            "text": "各リストを更新しました。更新内容は以下の通りです。\n\n1. Blocked: $DAY_BEFORE\n2. Opened: $CHECK_DATE\n3. Updated: Get Around\n\n 以上です。Binさん、Junさん、ご確認宜しくお願い致します。\n\n\n https://www.airbnb.com/rooms"

        }]
    }
EOF`

## 通知送る
curl -X POST --data-urlencode "$publish_data" $WEBHOOK_URL
