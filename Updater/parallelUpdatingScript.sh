#!/bin/bash


#Here we only try 5 experiments

#Run Training Neural Nets Model by: Rscript trainModel.R [crimeType] [directory to training data] [directory to output model file] [Index of bagged Samples] [number of hidden node] [number of iterations]

##Iterations to update the model
currentDate=`date +%Y-%m-%d`


##Input parameter 1 is the datapath
DATAPATH=$1
echo $DATAPATH

MODELPATH=$1

##Input parameter 2 is the CRIMETYPE
CRIMETYPE=$2
echo $CRIMETYPE

##Input parameter 3 is the number of the neural nets
numOfNN=$3
echo $numOfNN

numOfIterations=$4
echo $numOfIterations

for i in `seq 1 $numOfNN`

do
echo $i

#if [ -f updateModel_${CRIMETYPE}_${i}.pbs ];
#then
#    rm updateModel_${CRIMETYPE}_${i}.pbs
#fi




## If you are running on ANL, uncomment the commented lines here to generate pbs files. 
## Write .pbs file to the directory 
#echo "#!/bin/sh
##PBS -N updateModel_${CRIMETYPE}_${i}.pbs
##PBS -l nodes=1:bigmem:ppn=8
##PBS -l walltime=24:00:00
##PBS -j oe
##PBS -o /home/mking/pbs_output

#DATAPATH=$DATAPATH
#MODELPATH=$MODELPATH

#WeatherAndCrimeROOT=/home/mking/src/

#cd \$WeatherAndCrimeROOT

## Add R script here
#export PATH=\$PATH:/soft/R/3.0.2/bin/

#Rscript updateNN.R ${CRIMETYPE} \$DATAPATH \$MODELPATH $i $numOfIterations $currentDate
#Rscript updateNN_NoWeather.R ${CRIMETYPE} \$DATAPATH \$MODELPATH $i $numOfIterations $currentDate
#" >> updateModel_${CRIMETYPE}_${i}.pbs
##uncomment this to submit .pbs file
#qsub updateModel_1${CRIMETYPE}_${i}.pbs


#Debugging version only( delete)
#DATAPATH="/Users/maggieking/Documents/WeatherandCrime/datapath"
#MODELPATH="/Users/maggieking/Documents/WeatherandCrime/datapath"
#Rscript updateNN.R $CRIMETYPE ${CRIMETYPE}_count $DATAPATH/$CRIMETYPE $MODELPATH/$CRIMETYPE $i $numOfIterations $currentDate

#Version without pbs
Rscript updateNN.R $CRIMETYPE ${CRIMETYPE}_count $DATAPATH/$CRIMETYPE $MODELPATH/$CRIMETYPE $i $numOfIterations $currentDate
Rscript updateNN_NoWeather.R $CRIMETYPE ${CRIMETYPE}_count $DATAPATH/$CRIMETYPE $MODELPATH/$CRIMETYPE $i $numOfIterations $currentDate



done
