
###########################################Training##########################################
nrow(homicideData)
nrow(homicideZeroData)
colnames(homicideData)
colnames(homicideZeroData)
length(unique(homicideZeroData$census_tra))

homicideAllData = rbind(homicideData[,1:28],homicideZeroData)

newData = data.frame(homicideAllData$census_tra, homicideAllData$year, homicideAllData$hournumber, homicideAllData$time,
                     homicideAllData$shooting_count,homicideAllData$wind_speed,homicideAllData$drybulb_fahrenheit,
                     homicideAllData$hourly_precip,homicideAllData$relative_humidity,homicideAllData$dod_drybulb_fahrenheit)
colnames(newData) <- c("census_tra", "year","hournumber","time",
                       "shooting_count","wind_speed","drybulb_fahrenheit",
                       "hourly_precip","relative_humidity","dod_drybulb_fahrenheit")
colnames(newData)


##handle missing data

newData[is.na(newData)] = 0
homicideAllData = na.omit(newData)



### binarize dataset

homicideAllData$truncateHumidity = homicideAllData$relative_humidity
homicideAllData$truncateHumidity[homicideAllData$truncateHumidity>
                                   quantile(homicideAllData$relative_humidity,
                                            probs = 0.98,names=FALSE)] = 
  quantile(homicideAllData$relative_humidity,probs = 0.98,names=FALSE)

homicideAllData$truncateHumidity[homicideAllData$truncateHumidity<
                           quantile(homicideAllData$relative_humidity,
                                    probs = 0.02,names=FALSE)] = 
  quantile(homicideAllData$relative_humidity,probs = 0.02,names=FALSE)
humidityBandwidth = (quantile(homicideAllData$relative_humidity,probs = 0.98,names=FALSE) + 0.1 -
                       quantile(homicideAllData$relative_humidity,probs = 0.02,names=FALSE)) / 30


homicideAllData$humidity_index = 
  floor((homicideAllData$truncateHumidity - 
           quantile(homicideAllData$relative_humidity,probs = 0.02,names=FALSE))/
          humidityBandwidth)
unique(homicideAllData$humidity_index)


homicideAllData$truncateTem = homicideAllData$drybulb_fahrenheit
homicideAllData$truncateTem[homicideAllData$truncateTem>
                                   quantile(homicideAllData$drybulb_fahrenheit,
                                            probs = 0.98,names=FALSE)] = 
  quantile(homicideAllData$drybulb_fahrenheit,probs = 0.98,names=FALSE)

homicideAllData$truncateTem[homicideAllData$truncateTem<
                                   quantile(homicideAllData$drybulb_fahrenheit,
                                            probs = 0.02,names=FALSE)] = 
  quantile(homicideAllData$drybulb_fahrenheit,probs = 0.02,names=FALSE)
tempBandwidth = (quantile(homicideAllData$drybulb_fahrenheit,probs = 0.98,names=FALSE) + 0.1 -
                       quantile(homicideAllData$drybulb_fahrenheit,probs = 0.02,names=FALSE)) / 30


homicideAllData$temp_index = 
  floor((homicideAllData$truncateTem - 
           quantile(homicideAllData$drybulb_fahrenheit,probs = 0.02,names=FALSE))/
          tempBandwidth)
unique(homicideAllData$temp_index)





homicideAllData$truncateWind = homicideAllData$wind_speed
homicideAllData$truncateWind[homicideAllData$truncateWind>
                              quantile(homicideAllData$wind_speed,
                                       probs = 0.98,names=FALSE)] = 
  quantile(homicideAllData$wind_speed,probs = 0.98,names=FALSE)

homicideAllData$truncateWind[homicideAllData$truncateWind<
                              quantile(homicideAllData$wind_speed,
                                       probs = 0.02,names=FALSE)] = 
  quantile(homicideAllData$wind_speed,probs = 0.02,names=FALSE)
windBandwidth = (quantile(homicideAllData$wind_speed,probs = 0.98,names=FALSE) + 0.1 -
                   quantile(homicideAllData$wind_speed,probs = 0.02,names=FALSE)) / 30


homicideAllData$wind_index = 
  floor((homicideAllData$truncateWind - 
           quantile(homicideAllData$wind_speed,probs = 0.02,names=FALSE))/
          windBandwidth)
unique(homicideAllData$wind_index)




homicideAllData$truncatePreci = homicideAllData$hourly_precip
homicideAllData$truncatePreci[homicideAllData$truncatePreci>
                               quantile(homicideAllData$hourly_precip,
                                        probs = 0.98,names=FALSE)] = 
  quantile(homicideAllData$hourly_precip,probs = 0.98,names=FALSE)

homicideAllData$truncatePreci[homicideAllData$truncatePreci<
                               quantile(homicideAllData$hourly_precip,
                                        probs = 0.02,names=FALSE)] = 
  quantile(homicideAllData$hourly_precip,probs = 0.02,names=FALSE)
precipBandwidth = (quantile(homicideAllData$hourly_precip,probs = 0.98,names=FALSE) + 0.001 -
                   quantile(homicideAllData$hourly_precip,probs = 0.02,names=FALSE)) / 30


homicideAllData$preci_index = 
  floor((homicideAllData$truncatePreci - 
           quantile(homicideAllData$hourly_precip,probs = 0.02,names=FALSE))/
          precipBandwidth)
unique(homicideAllData$preci_index)




homicideAllData$truncateDod = homicideAllData$dod_drybulb_fahrenheit
homicideAllData$truncateDod[homicideAllData$truncateDod>
                                quantile(homicideAllData$dod_drybulb_fahrenheit,
                                         probs = 0.98,names=FALSE)] = 
  quantile(homicideAllData$dod_drybulb_fahrenheit,probs = 0.98,names=FALSE)

homicideAllData$truncateDod[homicideAllData$truncateDod<
                                quantile(homicideAllData$dod_drybulb_fahrenheit,
                                         probs = 0.02,names=FALSE)] = 
  quantile(homicideAllData$dod_drybulb_fahrenheit,probs = 0.02,names=FALSE)
dodBandwidth = (quantile(homicideAllData$dod_drybulb_fahrenheit,probs = 0.98,names=FALSE) + 0.001 -
                     quantile(homicideAllData$dod_drybulb_fahrenheit,probs = 0.02,names=FALSE)) / 30


homicideAllData$dod_index = 
  floor((homicideAllData$truncateDod - 
           quantile(homicideAllData$dod_drybulb_fahrenheit,probs = 0.02,names=FALSE))/
          dodBandwidth)
unique(homicideAllData$dod_index)
homicideAllData$month = strftime(homicideAllData$time, "%m")
homicideAllData$day = strftime(homicideAllData$time, "%d")

mo <- strftime(homicideAllData$time[1], "%d")
colnames(homicideAllData)

homicideAllData$census_tra = factor(homicideAllData$census_tra)
homicideAllData$year = factor(homicideAllData$year)
homicideAllData$hournumber = factor(homicideAllData$hournumber)
homicideAllData$humidity_index = factor(homicideAllData$humidity_index)
homicideAllData$temp_index = factor(homicideAllData$temp_index)
homicideAllData$wind_index = factor(homicideAllData$wind_index)
homicideAllData$preci_index = factor(homicideAllData$preci_index)
homicideAllData$dod_index = factor(homicideAllData$dod_index)
homicideAllData$month = factor(homicideAllData$month)
homicideAllData$day = factor(homicideAllData$day)


homicideZeroDataNN = homicideAllData[which(homicideAllData$shooting_count==0),]
homicidePositiveDataNN = homicideAllData[which(homicideAllData$shooting_count!=0),]



bagging<-function(sampleSize, dataSet)
{
  dataSet[sample(nrow(dataSet),sampleSize),]
}
par(mfrow = c(1,1))

baggedZeroNN = bagging(nrow(homicidePositiveDataNN),homicideZeroDataNN)
newTraining = rbind(baggedZeroNN, homicidePositiveDataNN)

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


m <- model.matrix( 
  ~census_tra + hournumber + shooting_count + humidity_index
  + temp_index + wind_index + preci_index + dod_index + month
  + day,
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



##binarize finished###

##start to build model and train###

n = data.frame(m)
colnames(n)
names = names(n)
names = names[2:length(names)]

for (i in c(1:ncol(n))){
  n[,i] = as.integer(n[,i])
}


save(n,file = "~/Desktop/training_batch_20.RData")


library(grid)
library(neuralnet)



f <- as.formula(paste("shooting_count ~", paste(names[!names %in% "shooting_count"], collapse = " + ")))
f

write.csv(n, "./Desktop/finalTraining.csv")
n = read.csv("./Desktop/trainingData.csv")
write.csv(newTraining, "./Desktop/baggedNewTraining.csv")

library(NeuralNetTools)
library(nnet)

# train the model
ir.nn3 <- nnet(f, data = n, size = 10, rang = 0.1,MaxNWts = 30000,
               decay = 5e-4, maxit = 200)

#load("~/Desktop//important.RData")

############################# TESTING CODE ############################################



testHomicideZeroData = testingData[which(testingData$shooting_count==0),]


testHomicideData = testingData[which(testingData$shooting_count>0),]
nrow(testingData)

#Binarize testing data

newData = data.frame(testingData$census_tra, testingData$year, testingData$hournumber, testingData$time,
                     testingData$shooting_count,testingData$wind_speed,testingData$drybulb_fahrenheit,
                     testingData$hourly_precip,testingData$relative_humidity,testingData$dod_drybulb_fahrenheit)

colnames(newData) <- c("census_tra", "year","hournumber","time",
                       "shooting_count","wind_speed","drybulb_fahrenheit",
                       "hourly_precip","relative_humidity","dod_drybulb_fahrenheit")
newData[is.na(newData)] = 0

testHomicideAllData = na.omit(newData)


testHomicideAllData$truncateHumidity = testHomicideAllData$relative_humidity
testHomicideAllData$truncateHumidity[testHomicideAllData$truncateHumidity>
                                       quantile(homicideAllData$relative_humidity,
                                                probs = 0.98,names=FALSE)] = 
  quantile(homicideAllData$relative_humidity,probs = 0.98,names=FALSE)

testHomicideAllData$truncateHumidity[testHomicideAllData$truncateHumidity<
                                       quantile(homicideAllData$relative_humidity,
                                                probs = 0.02,names=FALSE)] = 
  quantile(homicideAllData$relative_humidity,probs = 0.02,names=FALSE)
humidityBandwidth = (quantile(homicideAllData$relative_humidity,probs = 0.98,names=FALSE) + 0.1 -
                       quantile(homicideAllData$relative_humidity,probs = 0.02,names=FALSE)) / 30


testHomicideAllData$humidity_index = 
  floor((testHomicideAllData$truncateHumidity - 
           quantile(homicideAllData$relative_humidity,probs = 0.02,names=FALSE))/
          humidityBandwidth)
unique(testHomicideAllData$humidity_index)



testHomicideAllData$truncateTem = testHomicideAllData$drybulb_fahrenheit
testHomicideAllData$truncateTem[testHomicideAllData$truncateTem>
                                  quantile(homicideAllData$drybulb_fahrenheit,
                                           probs = 0.98,names=FALSE)] = 
  quantile(homicideAllData$drybulb_fahrenheit,probs = 0.98,names=FALSE)

testHomicideAllData$truncateTem[testHomicideAllData$truncateTem<
                                  quantile(homicideAllData$drybulb_fahrenheit,
                                           probs = 0.02,names=FALSE)] = 
  quantile(homicideAllData$drybulb_fahrenheit,probs = 0.02,names=FALSE)
tempBandwidth = (quantile(homicideAllData$drybulb_fahrenheit,probs = 0.98,names=FALSE) + 0.1 -
                   quantile(homicideAllData$drybulb_fahrenheit,probs = 0.02,names=FALSE)) / 30


testHomicideAllData$temp_index = 
  floor((testHomicideAllData$truncateTem - 
           quantile(homicideAllData$drybulb_fahrenheit,probs = 0.02,names=FALSE))/
          tempBandwidth)
unique(testHomicideAllData$temp_index)





testHomicideAllData$truncateWind = testHomicideAllData$wind_speed
testHomicideAllData$truncateWind[testHomicideAllData$truncateWind>
                                   quantile(homicideAllData$wind_speed,
                                            probs = 0.98,names=FALSE)] = 
  quantile(homicideAllData$wind_speed,probs = 0.98,names=FALSE)

testHomicideAllData$truncateWind[testHomicideAllData$truncateWind<
                                   quantile(homicideAllData$wind_speed,
                                            probs = 0.02,names=FALSE)] = 
  quantile(homicideAllData$wind_speed,probs = 0.02,names=FALSE)
windBandwidth = (quantile(homicideAllData$wind_speed,probs = 0.98,names=FALSE) + 0.1 -
                   quantile(homicideAllData$wind_speed,probs = 0.02,names=FALSE)) / 30


testHomicideAllData$wind_index = 
  floor((testHomicideAllData$truncateWind - 
           quantile(homicideAllData$wind_speed,probs = 0.02,names=FALSE))/
          windBandwidth)
unique(testHomicideAllData$wind_index)




testHomicideAllData$truncatePreci = testHomicideAllData$hourly_precip
testHomicideAllData$truncatePreci[testHomicideAllData$truncatePreci>
                                    quantile(homicideAllData$hourly_precip,
                                             probs = 0.98,names=FALSE)] = 
  quantile(homicideAllData$hourly_precip,probs = 0.98,names=FALSE)

testHomicideAllData$truncatePreci[testHomicideAllData$truncatePreci<
                                    quantile(homicideAllData$hourly_precip,
                                             probs = 0.02,names=FALSE)] = 
  quantile(homicideAllData$hourly_precip,probs = 0.02,names=FALSE)
precipBandwidth = (quantile(homicideAllData$hourly_precip,probs = 0.98,names=FALSE) + 0.001 -
                     quantile(homicideAllData$hourly_precip,probs = 0.02,names=FALSE)) / 30


testHomicideAllData$preci_index = 
  floor((testHomicideAllData$truncatePreci - 
           quantile(homicideAllData$hourly_precip,probs = 0.02,names=FALSE))/
          precipBandwidth)
unique(testHomicideAllData$preci_index)




testHomicideAllData$truncateDod = testHomicideAllData$dod_drybulb_fahrenheit
testHomicideAllData$truncateDod[testHomicideAllData$truncateDod>
                                  quantile(homicideAllData$dod_drybulb_fahrenheit,
                                           probs = 0.98,names=FALSE)] = 
  quantile(homicideAllData$dod_drybulb_fahrenheit,probs = 0.98,names=FALSE)

testHomicideAllData$truncateDod[testHomicideAllData$truncateDod<
                                  quantile(homicideAllData$dod_drybulb_fahrenheit,
                                           probs = 0.02,names=FALSE)] = 
  quantile(homicideAllData$dod_drybulb_fahrenheit,probs = 0.02,names=FALSE)
dodBandwidth = (quantile(homicideAllData$dod_drybulb_fahrenheit,probs = 0.98,names=FALSE) + 0.001 -
                  quantile(homicideAllData$dod_drybulb_fahrenheit,probs = 0.02,names=FALSE)) / 30


testHomicideAllData$dod_index = 
  floor((testHomicideAllData$truncateDod - 
           quantile(homicideAllData$dod_drybulb_fahrenheit,probs = 0.02,names=FALSE))/
          dodBandwidth)
unique(testHomicideAllData$dod_index)
testHomicideAllData$month = strftime(testHomicideAllData$time, "%m")
testHomicideAllData$day = strftime(testHomicideAllData$time, "%d")

testHomicideAllData$year

testHomicideAllData$census_tra = factor(testHomicideAllData$census_tra)
testHomicideAllData$year = factor(testHomicideAllData$year)
testHomicideAllData$hournumber = factor(testHomicideAllData$hournumber)
testHomicideAllData$humidity_index = factor(testHomicideAllData$humidity_index)
testHomicideAllData$temp_index = factor(testHomicideAllData$temp_index)
testHomicideAllData$wind_index = factor(testHomicideAllData$wind_index)
testHomicideAllData$preci_index = factor(testHomicideAllData$preci_index)
testHomicideAllData$dod_index = factor(testHomicideAllData$dod_index)
testHomicideAllData$month = factor(testHomicideAllData$month)
testHomicideAllData$day = factor(testHomicideAllData$day)

testHomicideAllData <- model.matrix( 
  ~census_tra + hournumber + shooting_count + humidity_index
  + temp_index + wind_index + preci_index + dod_index + month
  + day,
  data = testHomicideAllData,
  contrasts.arg=list(census_tra=contrasts(testHomicideAllData$census_tra, contrasts=F), 
                     hournumber=contrasts(testHomicideAllData$hournumber, contrasts=F), 
                     humidity_index=contrasts(testHomicideAllData$humidity_index, contrasts=F), 
                     temp_index=contrasts(testHomicideAllData$temp_index, contrasts=F), 
                     wind_index=contrasts(testHomicideAllData$wind_index, contrasts=F), 
                     preci_index=contrasts(testHomicideAllData$preci_index, contrasts=F), 
                     dod_index=contrasts(testHomicideAllData$dod_index, contrasts=F), 
                     month=contrasts(testHomicideAllData$month, contrasts=F), 
                     day=contrasts(testHomicideAllData$day, contrasts=F) 
  )
)




colnames(testHomicideAllData)
names = names(testHomicideAllData)
names = names[2:length(names)]

for (i in c(1:ncol(testHomicideAllData))){
  testHomicideAllData[,i] = as.integer(testHomicideAllData[,i])
}

testHomicideAllData = data.frame(testHomicideAllData)
testPositiveData = testHomicideAllData[which(testHomicideAllData$shooting_count != 0),]
testNegativeData = testHomicideAllData[which(testHomicideAllData$shooting_count == 0),]
testHomicideAllData$month10 = 0
testHomicideAllData$month11 = 0
testHomicideAllData$month12 = 0
testNegativeData$month10 = 0
testNegativeData$month11 = 0
testNegativeData$month12 = 0


#Start to predict

predictedPositiveTest=predict(ir.nn3, testPositiveData, type = "raw")
save.image(file="workspace21.RData")
predictedNegativeTest=predict(ir.nn3, testNegativeData, type = "raw")

#==============================



