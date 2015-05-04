#************************* Code can NOT be parallized: Data Preparation*******************************#

library(grid)
library(neuralnet)
library(NeuralNetTools)
library(nnet)

###################### Prepare Training Data ############################
crimeDataFileDirectory = "/mnt/research_disk_1/newhome/weather_crime/data/WeatherCrimeJan2015.csv"
crimeData = read.csv(crimeDataFileDirectory)

#Split training and testing data from CrimeData
crimeData$time = as.POSIXct(crimeData$hourstart, format="%Y-%m-%d %H:%M:%S")

homicideAllData = crimeData[which(crimeData$time < as.POSIXct("2014-01-01", format="%Y-%m-%d")
                           & crimeData$time >= as.POSIXct("2009-01-01", format="%Y-%m-%d")),]
testHomicideAllData = crimeData[which(crimeData$time >= as.POSIXct("2014-01-01", format="%Y-%m-%d")),]



###Specify What Kind of Crime In Interest#####
##Robbery, shooting, ...##
crimeType = "robbery"


## Binarize Data
homicideAllData = binarizeTrainingData(homicideAllData,crimeType)

homicideZeroDataNN = homicideAllData[which(homicideAllData[,crimeType]==0),]
homicidePositiveDataNN = homicideAllData[which(homicideAllData[,crimeType]!=0),]




################### Prepare Testing Data #################################
#Binarize testing data
testHomicideAllData = binarizeTestingData(homicideAllData,testHomicideAllData,crimeType)

testHomicideAllData = data.frame(testHomicideAllData)
testPositiveData = testHomicideAllData[which(testHomicideAllData[,crimeType] != 0),]
testNegativeData = testHomicideAllData[which(testHomicideAllData[,crimeType] == 0),]


##Because the test data we have doesn't have Oct, Nov and Dec! have to manually add it. This step can be skipped if we have enough data.
testHomicideAllData$month10 = 0
testHomicideAllData$month11 = 0
testHomicideAllData$month12 = 0
testNegativeData$month10 = 0
testNegativeData$month11 = 0
testNegativeData$month12 = 0







######Bagging Function

bagging<-function(sampleSize, dataSet)
{
  dataSet[sample(nrow(dataSet),sampleSize),]
}



#************************* Code CAN be parallized: Model Training*******************************#



###########################################Training##########################################




## Training one batch can be binarized

## Bag Select Data
baggedZeroNN = bagging(nrow(homicidePositiveDataNN),homicideZeroDataNN)
newTraining = rbind(baggedZeroNN, homicidePositiveDataNN)


## Prepare bagged data
newTraining$census_tra = factor(newTraining$census_tra)
newTraining$year = factor(newTraining$year)
newTraining$hournumber = factor(newTraining$hournumber)
newTraining$humidity_index = factor(newTraining$humidity_index)
newTraining$temp_index = factor(newTraining$temp_index)
newTraining$wind_index = factor(newTraining$wind_index)
newTraining$preci_index = factor(newTraining$preci_index)
newTraining$dod_index = factor(newTraining$dod_index)
newTraining$month = factor(newTraining$month)
newTraining$day = factor(newTraining$day)


## Make the attributes binary.

names = names(newTraining)
m <- model.matrix(
  paste("~",paste(names[!names %in% "year"],collapse = "+"), 
  data = newTraining,
  contrasts.arg=list(census_tra=contrasts(newTraining$census_tra, contrasts=F), 
                     hournumber=contrasts(newTraining$hournumber, contrasts=F), 
                     humidity_index=contrasts(newTraining$humidity_index, contrasts=F), 
                     temp_index=contrasts(newTraining$temp_index, contrasts=F), 
                     wind_index=contrasts(newTraining$wind_index, contrasts=F), 
                     preci_index=contrasts(newTraining$preci_index, contrasts=F), 
                     dod_index=contrasts(newTraining$dod_index, contrasts=F), 
                     month=contrasts(newTraining$month, contrasts=F), 
                     day=contrasts(newTraining$day, contrasts=F) 
  )
)
n = data.frame(m)
colnames(n)
names = names(n)
names = names[2:length(names)]

## Manually transfer the attributes into integer.

for (i in c(1:ncol(n))){
  n[,i] = as.integer(n[,i])
}

#save(n,file = "~/Desktop/training_batch_20.RData")

##binarize finished###


##start to build model and train###


f <- as.formula(paste(paste(crimeType," ~"), paste(names[!names %in% "shooting_count"], collapse = " + ")))

#write.csv(n, "./Desktop/finalTraining.csv")
#n = read.csv("./Desktop/trainingData.csv")
#write.csv(newTraining, "./Desktop/baggedNewTraining.csv")


# train the model
ir.nn3 <- nnet(f, data = n, size = 10, rang = 0.1,MaxNWts = 30000,
               decay = 5e-4, maxit = 200)

#load("~/Desktop//important.RData")

############################# TESTING CODE ############################################

#Start to predict

predictedPositiveTest=predict(ir.nn3, testPositiveData, type = "raw")
save.image(file="workspace21.RData")
predictedNegativeTest=predict(ir.nn3, testNegativeData, type = "raw")

#==============================



