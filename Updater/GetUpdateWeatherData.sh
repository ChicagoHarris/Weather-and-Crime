#!/bin/bash

#brew install jq
#brew install wget
#brew install go
#go get github.com/jehiah/json2csv

mkdir weatherjsons
cd weatherjsons

YEAR_today=`date +%Y`
MONTH_today=`date +%m`
DAY_today=`date +%d`

latestDate=`cat ../crimecsvs/latestDate.txt`
LatestData_YEAR=`cat ../crimecsvs/latestDate.txt|cut -f1 -d '-'`
LatestData_MONTH=`cat ../crimecsvs/latestDate.txt|cut -f2 -d '-'`
LatestData_DAY=`cat ../crimecsvs/latestDate.txt|cut -f3 -d '-'`


wbans="94846 14855 04807 14819 94866 04831"
for wban in $wbans; do
for year in `seq $LatestData_YEAR $LatestData_YEAR`; do
for month in `seq $LatestData_MONTH $LatestData_MONTH`; do 

echo $LatestData_DAY
echo $LatestData_YEAR
echo $LatestData_MONTH


previousMonth=$(($month - 1))
echo $previousMonth
nextyear=$year
if [ $previousMonth -eq 0 ]; then
previousMonth=12
nextyear=$year
fi
day=$(($LatestData_DAY + 1))
url="http://plenar.io/v1/api/weather/hourly/?wban_code=$wban&datetime__ge=$year-$previousMonth-$day&datetime__lt=$year-$month-$day"
echo $url
curl -o $wban.$year.$month.json $url
sleep 5
done
done
done

wbans="94846 14855 04807 14819 94866 04831"
for wban in $wbans; do
for year in `seq $LatestData_YEAR $LatestData_YEAR`; do
for month in `seq $LatestData_MONTH $LatestData_MONTH`; do 

jq -c '.objects[0].observations[]' $wban.$year.$month.json > $wban.$year.$month.obs.json
done
done
done

######make sure you are in ONYL a weatherjsons folder before you run following command— deletes all files below 1k within folder
find . -size -1k -name "*.json" -delete

echo "wind_speed,sealevel_pressure,old_station_type,station_type,sky_condition,wind_direction,sky_condition_top,visibility,datetime,wind_direction_cardinal,relative_humidity,hourly_precip,drybulb_fahrenheit,report_type,dewpoint_fahrenheit,station_pressure,weather_types,wetbulb_fahrenheit,wban_code" > ChicagoWeather_Update_${YEAR_today}_${MONTH_today}_${DAY_today}.csv

wbans="94846 14855 04807 14819 94866 04831"
for wban in $wbans; do
for year in `seq $LatestData_YEAR $LatestData_YEAR`; do
for month in `seq $LatestData_MONTH $LatestData_MONTH`; do 
file=$wban.$year.$month.obs.json
if [ -f $file ];then
$HOME/work/bin/json2csv -i $file -k wind_speed,sealevel_pressure,old_station_type,station_type,sky_condition,wind_direction,sky_condition_top,visibility,datetime,wind_direction_cardinal,relative_humidity,hourly_precip,drybulb_fahrenheit,report_type,dewpoint_fahrenheit,station_pressure,weather_types,wetbulb_fahrenheit,wban_code >> ChicagoWeather_Update_${YEAR_today}_${MONTH_today}_${DAY_today}.csv
fi
done
done
done





