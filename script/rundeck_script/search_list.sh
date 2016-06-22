#!/bin/bash

NAME="asuka"
PUBLISH_CHANNEL="#release"
TEST_CHANNEL="test"

## asuka用
#WEBHOOK_URL=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

CHECK_MONTH="$(date -v+4m +'%m')"
CHECK_YEAR="$(date -v+4m +'%Y')"

LAST_DAY="$(cal $CHECK_MONTH $CHECK_YEAR | egrep -e '^ [0-9]|^[0-9]' | tr '\n' ' ' | awk '{print $NF}')"

FIRST_DATE=$CHECK_YEAR-$CHECK_MONTH-01
LAST_DATE=$CHECK_YEAR-$CHECK_MONTH-$LAST_DAY

LOCATION="Tokyo%2C%20Shinjuku"

echo $FIRST_DATE
echo $LAST_DATE

curl https://api.airbnb.com/v2/search_results?client_id=3092nxybyb0otqw18e8nh5nty&locale=en-US&currency=USD&_format=for_search_results_with_minimal_pricing&_limit=10&_offset=0&fetch_facets=true&guests=1&ib=false&ib_add_photo_flow=true&location=$LOCATION&min_bathrooms=0&min_bedrooms=0&min_beds=1&min_num_pic_urls=10&price_max=210&price_min=1&sort=1
