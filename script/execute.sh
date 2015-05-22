#!/bin/bash

DATAPATH=/mnt/research_disk_1/newhome/weather_crime/data/

#Run preprocess data by: Rscript preprocessData.R [crimeType] [number of bins for continous variables] [number of bagged samples] [directory to rawData] [directory to output training data] [directory to output testing data]

Rscript ../src/preprocessData.R "robbery_count" 15 5 $DATAPATH/WeatherCrimeJan2008-2015.csv $DATAPATH $DATAPATH

#Run Training Neural Nets Model by: Rscript trainModel.R [crimeType] [directory to training data] [directory to output model file] [Index of bagged Samples: {1,2,3,...number of bagged samples}] [number of hidden node] [number of iterations]
#Here we use command "parallel" to parallelize the training on bagged training samples

parallel Rscript ../src/trainNN.R "robbery_count" $DATAPATH $DATAPATH {1} 10 20 ::: {1..5}

#Run testing model by: Rscript testModel.R [crimeType] [directory to testing data] [direcotory to model file] [directory to output prediction file] [number of bagged samples]

Rscript ../src/testNN.R "robbery_count" $DATAPATH $DATAPATH $DATAPATH 5



#Run Updating Neural Nets Model by: Rscript updateNN.R [crimeType] [directory to updated data] [directory to base model file] [Index of bagged Samples: {1,2,3,...number of bagged samples}] [number of hidden node] [number of iterations] [datetime of updating]
#Here we use command "parallel" to parallelize the updating on bagged updated training samples

parallel Rscript ../src/updateNN.R "robbery_count" $DATAPATH $DATAPATH {1} 10 "2015-05-20" ::: {1..5}
