#!/bin/bash


#Run preprocess data by: Rscript preprocessData.R [crimeType] [number of bins for continous variables] [number of bagged samples] [directory to rawData] [directory to output training data] [directory to output testing data]

#Rscript ../src/preprocessData.R "robbery_count" 30 5 "/mnt/research_disk_1/newhome/weather_crime/data/WeatherCrimeJan2015.csv" "/mnt/research_disk_1/newhome/weather_crime/data" "/mnt/research_disk_1/newhome/weather_crime/data"

#Run Training Neural Nets Model by: Rscript trainModel.R [crimeType] [directory to training data] [directory to output model file] [Index of bagged Samples: {1,2,3,...number of bagged samples}] [number of hidden node] [number of iterations]

#parallel Rscript ../src/trainNN.R "robbery_count" "/mnt/research_disk_1/newhome/weather_crime/data" "/mnt/research_disk_1/newhome/weather_crime/data" {1} 10 200 ::: {1..5}

#Run testing model by: Rscript testModel.R [crimeType] [directory to testing data] [direcotory to model file] [directory to output prediction file] [number of bagged samples]

Rscript ../src/testNN.R "robbery_count" "/mnt/research_disk_1/newhome/weather_crime/data" "/mnt/research_disk_1/newhome/weather_crime/data" "/mnt/research_disk_1/newhome/weather_crime/data" 5
