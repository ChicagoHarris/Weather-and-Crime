mydata = read.csv("~/Google Drive/Copy of WeatherCrime2012_2014.csv")
mydata <- within(mydata, {
  dt <- strftime(dt,format = "%Y-%M-%D %H:%M:%S")
  census_tra <- factor(census_tra)
})

head(mydata)
crimeData = data.frame(mydata)
nrow(crimeData)

testingData = crimeData[seq(from=15000000,to = 21115022,by = 1),]
testingHomicideData = testingData[which(testingData$homicide_count>0),]
testingRobberyData = testingData[which(testingData$robbery_count>0),]
testingAssaultData = testingData[which(testingData$assault_count>0),]
testingZeroData = testingData[which(testingData$homicide_count==0 & testingData$robbery_count==0 & testingData$assault_count==0),]




trainingData = crimeData[seq(from = 1, to=15000000, by = 1),]

homicideData = trainingData[which(trainingData$homicide_count>0),]
robberyData = trainingData[which(trainingData$robbery_count>0),]
assaultData = trainingData[which(trainingData$assault_count>0),]
homicideDataSize = nrow(homicideData)
robberyDataSize = nrow(robberyData)
assaultDataSize = nrow(assaultData)
zeroData = trainingData[which(trainingData$homicide_count==0 & trainingData$robbery_count==0 & trainingData$assault_count==0),]

bagging<-function(sampleSize, dataSet)
{
  dataSet[sample(nrow(dataSet),sampleSize),]
}
newx = array(data = x,dim = 2 * nrow(homicideData))
x1 = seq(from = 0, to = 0,length.out=2 * nrow(homicideData))
x2 = seq(from = 0, to = 0,length.out=2 * nrow(testingHomicideData))
sampleTimes = 1000
library(rpart)
homicideDataSize = nrow(testingHomicideData)
trainingbaggedZeroData = bagging(homicideDataSize,testingZeroData)
training = rbind(data.frame(trainingbaggedZeroData), testingHomicideData)
for (i in c(1:sampleTimes))
{

baggedZeroData = bagging(homicideDataSize,zeroData)
newTraining = rbind(baggedZeroData, homicideData)
totalSize = nrow(newTraining)
## This is a tree regression part

## change method to "anova" to get a regression tree; change method to "class" to get a decision tree
fit = rpart(homicide_count~drybulb_fahrenheit+wind_speed+relative_humidity+fz+ra+ts+br+sn+hz+dz+pl+fg+sa+up+fu+sq+gs,
            newTraining,method = "anova",cp = 0.001)
#fit$cptable
fir=data.frame(predict(fit,newdata = training))
#printcp(fit)
#plotcp(fit)
#plot(fit)
#text(fit)
x2 = x2 + fir$predict.fit.
#fir2 = data.frame(predict(fit,newdata = testingZeroData))
#x2 = x2 + fir2$predict.fit.
}

plot(x2)