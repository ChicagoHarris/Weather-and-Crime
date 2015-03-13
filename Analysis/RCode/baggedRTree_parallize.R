setwd("/mnt/research_disk_1/newhome/weather_crime/data")
crimeData = read.csv("WeatherCrimeJan2015.csv")
crimeData$time = as.POSIXct(crimeData$hourstart, format="%Y-%m-%d %H:%M:%S")
trainingData = crimeData[which(crimeData$time < as.POSIXct("2014-01-01", format="%Y-%m-%d")),]
testingData = crimeData[which(crimeData$time >= as.POSIXct("2014-01-01", format="%Y-%m-%d")),]


testHomicideData = testingData[which(testingData$shooting_count>0),]
testHomicideZeroData = testingData[which(testingData$shooting_count==0),]
testRobberyData = testingData[which(testingData$robbery_count>0),]
testRobberyZeroData = testingData[which(testingData$robbery_count==0),]
testAssaultData = testingData[which(testingData$assault_count>0),]
testAssaultZeroData = testingData[which(testingData$assault_count==0),]


homicideData = trainingData[which(trainingData$shooting_count>0),]
homicideZeroData = trainingData[which(trainingData$shooting_count==0),]
robberyData = trainingData[which(trainingData$robbery_count>0),]
robberyZeroData = trainingData[which(trainingData$robbery_count==0),]
assaultData = trainingData[which(trainingData$assault_count>0),]
assaultZeroData = trainingData[which(trainingData$assault_count==0),]


## bagging function to sample from zerocases
bagging<-function(sampleSize, dataSet)
{
  dataSet[sample(nrow(dataSet),sampleSize),]
}


homicideDataSize = nrow(homicideData)
robberyDataSize = nrow(robberyData)
assaultDataSize = nrow(assaultData)
library(rpart)

sampleTimes = 200
x1 = seq(from = 0, to = 0,length.out=nrow(testHomicideZeroData))
x2 = seq(from = 0, to = 0,length.out=nrow(testHomicideData))

doOneBagging = function(i) {
  baggedZeroData = bagging(homicideDataSize,homicideZeroData)
  newTraining = rbind(baggedZeroData, homicideData)
  totalSize = nrow(newTraining)
  ## This is a tree regression part
  rPartFit = rpart(shooting_count~factor(census_tra) + drybulb_fahrenheit+wind_speed+relative_humidity+fz+ra+ts+br+sn+hz+dz+pl+fg+sa+up+fu+sq+gs,
                   newTraining,method = "anova", cp = 0.002)

  firPositive=data.frame(predict(rPartFit,newdata = testHomicideData))
  colnames(firPositive) <- c("fit")
  firNegative=data.frame(predict(rPartFit,newdata = testHomicideZeroData))
  colnames(firNegative) <- c("fit")

  posResult = firPositive$fit
  negResult = firNegative$fit
  return(list(posResult, negResult,rPartFit))
}


library(parallel)
# Parallelize Running Bagging procedure
system.time({out=mclapply(X=1:sampleTimes,FUN = doOneBagging, mc.cores=8)})

# Some useful function to calculate Recall and Error
posResult = x2/sampleTimes
posResult[posResult>=0.5] = 1
posResult[posResult<0.5] = 0
posRecall = mean(posResult)

negResult = x1/sampleTimes
negResult[negResult>=0.5] = 1
negResult[negResult<0.5] = 0
negError = mean(negResult)


#calculate accuracy for different area


## code for random effect regression tree with autoregression

# Manually setting all NA value equals to 0 in order to do random effect regression tree with AR
for(name in colnames(newTraining)){
  if(name == 'time')
    next
  newTraining[,name][is.na(newTraining[,name])] = 0}

for(name in colnames(testHomicideData)){
  if(name == 'time')
    next
  testHomicideData[,name][is.na(testHomicideData[,name])] = 0}


library(REEMtree)
data(simpleREEMdata)

# Use random effect on census tract. Use AR(1) on time
newTree<-REEMtree(shooting_count~drybulb_fahrenheit+hournumber+wind_speed+relative_humidity+fz+ra+ts+br+sn+hz+dz+pl+fg+sa+up+fu+sq+gs,
                          data = newTraining, random=~1|census_tra,
                          correlation = corAR1(form = ~time),cpmin = -Inf)

plotcp(tree(newTree))

newX = predict.REEMtree(newTree, testHomicideData,EstimateRandomEffects=FALSE)
hist(newX)

