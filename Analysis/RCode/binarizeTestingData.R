binarizeTestingData<-function(homicideAllData,testingData,crimeType){


newData = data.frame(testingData$census_tra, testingData$year, testingData$hournumber, testingData$time,
                     testingData[,crimeType],testingData$wind_speed,testingData$drybulb_fahrenheit,
                     testingData$hourly_precip,testingData$relative_humidity,testingData$dod_drybulb_fahrenheit)

colnames(newData) <- c("census_tra", "year","hournumber","time",
                       crimeType,"wind_speed","drybulb_fahrenheit",
                       "hourly_precip","relative_humidity","dod_drybulb_fahrenheit")


##handle missing data

newData[is.na(newData)] = 0
testHomicideAllData = na.omit(newData)



## binarize the data
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

names = names(testHomicideAllData)
testHomicideAllData <- model.matrix( 
  paste("~",paste(names[!names %in% "year"], collapse = "+")),
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

return testHomicideAllData
}
