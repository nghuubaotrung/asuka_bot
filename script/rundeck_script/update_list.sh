#!/bin/bash

NAME="asuka"
PUBLISH_CHANNEL="#release"
TEST_CHANNEL="test"

## asuka用
WEBHOOK_URL=xxxxxxxxxxxxxxxxxxxxxxxxx

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
LEO="14068452"

BABA_LIST=($FULL_HOUSE $CONY $BROWN)
HOUSE_LIST=($FULL_HOUSE $CONY $BROWN $LEO)

#sandbox用
#HOUSE_LIST=("7447209")

RESPONSE=200

for house in "${HOUSE_LIST[@]}"
do
    echo "update calendar"
    echo $AIRBNB_TOKEN
    echo $house

    # update Calendar
    # block The Day Before
    RESPONSE=$(curl -i -X PUT --compressed -H "X-Airbnb-OAuth-Token: $AIRBNB_TOKEN" \
        -H "Content-Type: application/json; charset=UTF-8" \
        --data-binary '{"availability":"unavailable"}' \
        https://api.airbnb.com/v2/calendars/$house/$DAY_BEFORE/$DAY_BEFORE \
        2>/dev/null | head -n 1 | cut -d$' ' -f2)

    # open Check Day
    RESPONSE=$(curl -i -X PUT --compressed -H "X-Airbnb-OAuth-Token: $AIRBNB_TOKEN" \
        -H "Content-Type: application/json; charset=UTF-8" \
        --data-binary '{"availability":"available"}' \
        https://api.airbnb.com/v2/calendars/$house/$CHECK_DATE/$CHECK_DATE \
        2>/dev/null | head -n 1 | cut -d$' ' -f2)

    sleep 1
done


# update Get Around for Baba List
for house in "${BABA_LIST[@]}"
do
    if [[ $((10#$CHECK_DAY % 2)) -eq 0 ]]; then
        echo "update list for even day"
        curl -i -X POST --compressed -H "X-Airbnb-OAuth-Token: $AIRBNB_TOKEN" \
            -H "Content-Type: application/json; charset=UTF-8" \
            --data-binary '{"listing":{"transit":"4 minutes train ride to Shinjuku station. (direct) \n4 minutes train ride to Ikebukuro station. (direct) \n9 minutes train ride to Harajuku station. (direct) \n11 minutes train ride to Shibuya station. (direct)"}}' \
            https://api.airbnb.com/v1/listings/$house/update?client_id=3092nxybyb0otqw18e8nh5nty&locale=en-US&currency=USD
    else
        echo "update list for odd day"
        curl -i -X POST --compressed -H "X-Airbnb-OAuth-Token: $AIRBNB_TOKEN" \
            -H "Content-Type: application/json; charset=UTF-8" \
            --data-binary '{"listing":{"transit":"4 minutes train ride to Shinjuku station. (Direct) \n4 minutes train ride to Ikebukuro station. (Direct) \n9 minutes train ride to Harajuku station. (Direct) \n11 minutes train ride to Shibuya station. (Direct)"}}' \
            https://api.airbnb.com/v1/listings/$house/update?client_id=3092nxybyb0otqw18e8nh5nty&locale=en-US&currency=USD
    fi

    sleep 1
done


# update Get Around for Leo
if [[ $((10#$CHECK_DAY % 2)) -eq 0 ]]; then
    echo "update list for even day"
    curl -i -X POST --compressed -H "X-Airbnb-OAuth-Token: $AIRBNB_TOKEN" \
        -H "Content-Type: application/json; charset=UTF-8" \
        --data-binary '{"listing":{"transit":"2 minutes train ride to Shinjuku station. (direct) \n6 minutes train ride to Ikebukuro station. (direct) \n7 minutes train ride to Harajuku station. (direct) \n9 minutes train ride to Shibuya station. (direct)"}}' \
        https://api.airbnb.com/v1/listings/$LEO/update?client_id=3092nxybyb0otqw18e8nh5nty&locale=en-US&currency=USD
else
    echo "update list for odd day"
    curl -i -X POST --compressed -H "X-Airbnb-OAuth-Token: $AIRBNB_TOKEN" \
        -H "Content-Type: application/json; charset=UTF-8" \
        --data-binary '{"listing":{"transit":"2 minutes train ride to Shinjuku station. (Direct) \n6 minutes train ride to Ikebukuro station. (Direct) \n7 minutes train ride to Harajuku station. (Direct) \n9 minutes train ride to Shibuya station. (Direct)"}}' \
        https://api.airbnb.com/v1/listings/$LEO/update?client_id=3092nxybyb0otqw18e8nh5nty&locale=en-US&currency=USD
fi


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
            "text": "各リストを更新しました。更新内容は以下の通りです。\n\n1. Blocked: $DAY_BEFORE\n2. Opened: $CHECK_DATE\n3. Updated: Get Around\n\n Request Response Code: $RESPONSE \n\n 以上です。Binさん、Junさん、ご確認宜しくお願い致します。\n\n\n https://www.airbnb.com/rooms"

        }]
    }
EOF`

## 通知送る
if [ $RESPONSE -ne 200 ]; then
    exit 1;
else
    curl -X POST --data-urlencode "$publish_data" $WEBHOOK_URL
fi
