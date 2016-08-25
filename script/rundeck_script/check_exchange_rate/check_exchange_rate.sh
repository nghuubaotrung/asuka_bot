#!/bin/bash
NAME="asuka"
JPY_VND_CHANNEL="#bnb"
EUR_VND_CHANNEL="#bin_test"

## asuka用
WEBHOOK_URL="xxxxxx"

LOCAL_PATH="/Users/nguyen_huubaotrung/Source-code/asuka_bot/script/rundeck_script/check_exchange_rate"

# get today's exchanger rate
TODAY_RATE_JP_VN=$(curl http://rate-exchange.herokuapp.com/fetchRate\?from\=JPY\&to\=VND | sed -e 's/[{}]/''/g' | cut -d , -f 3 | sed 's/.*\://' | bc -l)
TODAY_RATE_EU_VN=$(curl http://rate-exchange.herokuapp.com/fetchRate\?from\=EUR\&to\=VND | sed -e 's/[{}]/''/g' | cut -d , -f 3 | sed 's/.*\://' | bc -l)

echo $TODAY_RATE_JP_VN
echo $TODAY_RATE_EU_VN

# get old exchange rate from text files
OLD_RATE_JP_VN=`head $LOCAL_PATH/jpy_vnd.txt`
OLD_RATE_EU_VN=`head $LOCAL_PATH/eur_vnd.txt`

echo $OLD_RATE_JP_VN
echo $OLD_RATE_EU_VN

jpy_vnd_data=`cat << EOF
    payload={
        "channel": "$JPY_VND_CHANNEL",
        "username": "$NAME",
        "link_names": 1,
        "text": "お疲れ様です。jpy/vndの為替レートが下がりましたので、ご確認よろしくお願いいたします。\n\n昨日のレート: $OLD_RATE_JP_VN\n今日のレート: $TODAY_RATE_JP_VN"
    }
EOF`

eur_vnd_data=`cat << EOF
    payload={
        "channel": "$EUR_VND_CHANNEL",
        "username": "$NAME",
        "link_names": 1,
        "text": "お疲れ様です。eur/vndの為替レートが下がりましたので、ご確認よろしくお願いいたします。\n\n昨日のレート: $OLD_RATE_EU_VN\n今日のレート: $TODAY_RATE_EU_VN"
    }
EOF`

# update text file
sleep 1
rm $LOCAL_PATH/jpy_vnd.txt
rm $LOCAL_PATH/eur_vnd.txt

sleep 1
echo $TODAY_RATE_JP_VN >> $LOCAL_PATH/jpy_vnd.txt
echo $TODAY_RATE_EU_VN >> $LOCAL_PATH/eur_vnd.txt

# comparison
if [ "$OLD_RATE_JP_VN" \> "$TODAY_RATE_JP_VN" ]; then
    echo "jpy/vnd is getting low"
    curl -X POST --data-urlencode "$jpy_vnd_data" $WEBHOOK_URL
fi

if [ "$OLD_RATE_EU_VN" \> "$TODAY_RATE_EU_VN" ]; then
    echo "eur/vnd is getting low"
    curl -X POST --data-urlencode "$eur_vnd_data" $WEBHOOK_URL
fi
