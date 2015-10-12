#!/bin/bash


#Here we only try 5 experiments

#Run Training Neural Nets Model by: Rscript trainModel.R [crimeType] [directory to training data] [directory to output model file] [Index of bagged Samples] [number of hidden node] [number of iterations]

numOfHiddenNode=10
numOfIterations=200

for i in `seq 1 5`

do

## Write .pbs file to the directory 
echo "#!/bin/sh
#PBS -N trainModel_$i.pbs
#PBS -l nodes=1:bigmem:ppn=8
#PBS -l walltime=24:00:00
#PBS -j oe
#PBS -o /home/mking/pbs_output

WeatherAndCrimeROOT=/home/mking/src/
DATAPATH=/home/mking/WeatherCrimeJan2008-2015.csv

cd \$WeatherAndCrimeROOT

## Add R script here
export PATH=\$PATH:/soft/R/3.0.2/bin/

Rscript trainNN.R \"robbery_count\" \$DATAPATH \$DATAPATH $i $numOfHiddenNode $numOfIterations
" >> trainModel_$i.pbs


##uncomment this to submit .pbs file

#qsub trainModel_$i.pbs

done
