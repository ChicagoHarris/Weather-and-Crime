#!/bin/bash


#Run preprocess data by: Rscript preprocessData.R [crimeType] [directory to rawData] [directory to output training data] [directory to output testing data]

Rscript ../src/preprocessData.R "robbery_count" "/mnt/research_disk_1/newhome/weather_crime/data/WeatherCrimeJan2015.csv" "/mnt/research_disk_1/newhome/weather_crime/data/WeatherCrimeTraining09-13.csv" "/mnt/research_disk_1/newhome/weather_crime/data/WeatherCrimeTesting14.csv" 1

#Run Training Model by: Rscript trainModel.R [crimeType] [directory to training data] [random seed] [directory to output model file]

#Rscript ../src/trainModel.R "robbery_count" "/mnt/research_disk_1/newhome/weather_crime/data/WeatherCrimeJan2015.csv"

#Run testing model by: Rscript testModel.R [crimeType] [directory to testing data] [random seed] [direcotory to model file] [directory to output prediction file]


#Rscript ../src/testModel.R "robbery_count" "/mnt/research_disk_1/newhome/weather_crime/data/WeatherCrimeJan2015.csv"
