#/bin/bash

mkdir crimecsvs
cd crimecsvs


YEAR_today=`date +%Y`
MONTH_today=`date +%m`
DAY_today=`date +%d`

previousMonth=$(expr $MONTH_today - 1)
previousDay=$DAY_today
previousYear=$YEAR_today

if [ $previousMonth -eq 0 ]; then
previousMonth=12
previousYear=$(expr $previousYear - 1)
fi


url="http://plenar.io/v1/api/detail/?dataset_name=crimes_2001_to_present&obs_date__ge=$previousYear-$previousMonth-$previousDay&obs_date__lt=$YEAR_today-$MONTH_today-$DAY_today&data_type=csv"


echo $url
echo $previousMonth

curl -o temp.csv $url
cut -d ',' -f 5- temp.csv > temp1.csv
head -n1 temp1.csv > ChicagoCrime_Update_${YEAR_today}_${MONTH_today}_${DAY_today}.csv
# Only include first instance of duplicates
awk 'BEGIN{FS=","} $1=="1"' temp1.csv >> ChicagoCrime_Update_${YEAR_today}_${MONTH_today}_${DAY_today}.csv

rm temp.csv
rm temp1.csv

size=1
offset=1000 #Only 1000 rows are pulled each time
while [ $size -gt 0 ]
do
    url="http://plenar.io/v1/api/detail/?dataset_name=crimes_2001_to_present&obs_date__ge=$previousYear-$previousMonth-$previousDay&obs_date__lt=$YEAR_today-$MONTH_today-$DAY_today&offset=$offset&data_type=csv"
    echo $url
    curl -o temp.csv $url
    cut -d ',' -f 5- temp.csv > temp1.csv
    tail -n +2 temp1.csv > temp.csv
    size=$(cat temp.csv | wc -l)
    echo $size
    awk 'BEGIN{FS=","} $1=="1"' temp.csv >> ChicagoCrime_Update_${YEAR_today}_${MONTH_today}_${DAY_today}.csv
    #rm temp.csv
    #rm temp1.csv
    offset=$(($offset + 1000))
    echo $offset
done

cut -d ',' -f 1- ChicagoCrime_Update_${YEAR_today}_${MONTH_today}_${DAY_today}.csv > temp.csv
mv temp.csv ChicagoCrime_Update_${YEAR_today}_${MONTH_today}_${DAY_today}.csv
cut -d ',' -f 4 ChicagoCrime_Update_${YEAR_today}_${MONTH_today}_${DAY_today}.csv > datetimeTemp.csv
cut -d ' ' -f 1 datetimeTemp.csv > datetimeTemp1.csv
sort -t, -k1 datetimeTemp1.csv > sorted.csv
tail -2 sorted.csv | head -1 > datetimeTemp2.csv
tail -1 datetimeTemp2.csv > latestDate.txt
rm datetimeTemp.csv
rm datetimeTemp1.csv
rm datetimeTemp2.csv
rm sorted.csv
