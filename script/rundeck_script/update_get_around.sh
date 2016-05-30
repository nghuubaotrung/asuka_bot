#!/bin/bash

NAME="asuka"
PUBLISH_CHANNEL="#release"
TEST_CHANNEL="test"

## asuka用
WEBHOOK_URL=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

## 日付取得
CHECK_DATE="$(date -v+4m +'%Y-%m-%d')"
CHECK_DAY="$(date -v+4m +'%d')"
DAY_BEFORE="$(date -v+4m -v-1d +'%Y-%m-%d')"

# get Airbnb token
AIRBNB_TOKEN=$(curl -X POST -d "client_id=3092nxybyb0otqw18e8nh5nty" \
    -d "locale=en-US" \
    -d "currency=USD" \
    -d grant_type=password \
    -d password=xxxxxxxxxxxxx \
    -d username=tokiokichi202@gmail.com https://api.airbnb.com/v1/authorize | sed -e 's/[{}]/''/g' | cut -d , -f 1 | sed 's/.*\://' | sed 's/[^"]*"\([^"]*\)".*/\1/')

echo $AIRBNB_TOKEN
CHECK_DATE="$(date -v+4m +'%Y-%m-%d')"
CHECK_DAY="$(date -v+4m +'%d')"
DAY_BEFORE="$(date -v+4m -v-1d +'%Y-%m-%d')"

#本番
FULL_HOUSE="11398837"
CONY="11033998"
BROWN="11574448"

HOUSE_LIST=($FULL_HOUSE $CONY $BROWN)

#sandbox用
#HOUSE_LIST=("7447209")

for house in "${HOUSE_LIST[@]}"
do
    ### for odd days
    curl -i -X POST --compressed -H "X-Airbnb-OAuth-Token: $AIRBNB_TOKEN" \
        -H "Content-Type: application/json; charset=UTF-8" \
        --data-binary '{"listing":{"transit":"4 minutes train ride to Shinjuku station. ( Direct ) \n4 minutes train ride to Ikebukuro station. ( Direct ) \n9 minutes train ride to Harajuku station. ( Direct ) \n11 minutes train ride to Shibuya station. ( Direct )"}}' \
        https://api.airbnb.com/v1/listings/$house/update?client_id=3092nxybyb0otqw18e8nh5nty&locale=en-US&currency=USD
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
            "text": "各リストを更新しました。更新内容は以下の通りです。\n\nUpdated: Get Around\n\n 以上です。Binさん、Junさん、ご確認宜しくお願い致します。\n\n\n https://www.airbnb.com/rooms"

        }]
    }
EOF`

## 通知送る
curl -X POST --data-urlencode "$publish_data" $WEBHOOK_URL


