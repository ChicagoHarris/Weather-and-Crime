#!/bin/bash

# Assumes these paths are created and models exist in active models grouped in folders by crime type
DATAPATH=$(pwd)/bagged_data
MODELPATH=$(pwd)/active_models
ARCHIVE=$(pwd)/model_archive
AWS_PATH='../../data/Master_Pipeline/' # Relative path to models from home directory on EC2 instance currently assumes each crime is in its own folder


##Preparing Data: To pull updated crime and weather data from plenario [One month of data before current date]
##Updated crime data will be ./crimecsvs/ChicagoCrime_Update_{YYYY_MM_DD}.csv
##Updated weather data will be ./weatherjsons/ChicagoWeather_Update_{YYYY_MM_DD}.csv

YEAR_today=`date +%Y`
MONTH_today=`date +%m`
DAY_today=`date +%d`

cur_date=$MONTH_today-$DAY_today-$YEAR_today

# Backup current models, active ones will be overwritten by newer ones
cp -r active_models/ model_archive/$cur_date

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

bash ./bag_and_bin.sh WeatherandCrime_Data_Iter.csv 100 FALSE 1
for crimeType in "robbery" "shooting" "assault"
do 
    cd $crimeType
    gunzip *
    cp -r . $DATAPATH/$crimeType
    cd ..
done



##Submit jobs to Update Model (Before updating the model, the following script will also help to append updated binned and bagged data to historical bagged samples)

#declare -a crimeTypeNames=("robbery_count" "shooting_count" "assault_count")

##Here we use numofNN = number of base nns. Ie, if we have 100 base NN, then we should use numofNN=100 here.
numOfNN=100
numOfIterations=15
#for crimeType in `${crimeTypeNames[@]}`

#for crimeType in "robbery_count shooting_count assault_count"
for crimeType in "robbery" "shooting" "assault"
do
    bash ./parallelUpdatingScript.sh $DATAPATH $crimeType $numOfNN $numOfIterations $MODELPATH
done 

currentDate=`date +%Y-%m-%d`

echo $currentDate > modelUpdateDate.txt

# Script involving validation

# WeatherandCrime_Data_Iter.csv has all the data for the past month
# Use this use the validation dataset to validate the old models. 

python getValidation.py 

# Copy new models to EC2 instance, requires working .pem to transfer. Will overwrite files with the same name on the AWS instance
scp -r  -i uccdUser-key-pair.pem $ARCHIVE/.  ec2-user@ec2-52-35-83-231.us-west-2.compute.amazonaws.com:$AWS_PATH


