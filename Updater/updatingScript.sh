#!/bin/bash

#DATAPATH= [PATH TO DATA AND MODEL]
DATAPATH="/Users/maggieking/Documents/WeatherandCrime/datapath"


##Prepareing Data: To pull updated crime and weather data from plenario [One month of data before current date]
##Updated crime data will be ./crimecsvs/ChicagoCrime_Update_{YYYY_MM_DD}.csv
##Updated weather data will be ./weatherjsons/ChicagoWeather_Update_{YYYY_MM_DD}.csv

YEAR_today=`date +%Y`
MONTH_today=`date +%m`
DAY_today=`date +%d`

bash ./GetUpdateCrimeData.sh
bash ./GetUpdateWeatherData.sh



##Script involving postgres: To join weather and crime data to census tracts

## 1. Imports to postgresql census shape file. 
## 2. Imports to postgresql crime and weather data. 
## 3. Runs sql query to create csv that joins weather and crimes to census tracts.
#[After step 3, one month of joint data will be produced.]
## Note: Sql query exports a csv for only data from the latest date [We only need the data for the latest date] 

bash ./RunPostgres.sh weatherjsons/ChicagoWeather_Update_${YEAR_today}_${MONTH_today}_${DAY_today}.csv crimecsvs/ChicagoCrime_Update_${YEAR_today}_${MONTH_today}_${DAY_today}.csv





##Bag and bin: Related File: bag_and_bin.sh.
##Ideally, bag_and_bin.sh will take the data csv from DATAPATH, and produce bagged and bined csv file with filename in this format: .bagTrainingData_{CrimeType}_Update_{YYYY_MM_DD}_Index_{index of the bagged samples}.csv
# For example: .bagTrainingData_robbery_count_Update_2015_05_22_Index_5.csv

./bag_and_bin.sh WeatherandCrime_Data_Iter.csv 100



##Submit jobs to Update Model (Before updating the model, the following script will also help to append updated binned and bagged data to historical bagged samples)

#declare -a crimeTypeNames=("robbery_count" "shooting_count" "assault_count")

##Here we use numofNN = 5. But if we have 100 base NN, then we should use numofNN=100 here.
numofNN=100
numofIterations=10
#for crimeType in `${crimeTypeNames[@]}`

for crimeType in "robbery_count shooting_count assault_count"
do
    bash ./parallelUpdatingScript.sh $DATAPATH $crimeType $numofNN $numofIterations
done 

currentDate=`date +%Y-%m-%d`

echo $currentDate > modelUpdateDate.txt

# Script involving validation

# WeatherandCrime_Data_Iter.csv has all the data for the past month
# Use this use the validation dataset to validate the old models. 

python getValidation.py 
