#Data Clean up R#
binarizeTrainingData<-function(homicideAllData)
{
#homicideAllData = rbind(homicideData[,1:28],homicideZeroData)

# Select the useful data column to make a new dataframe so that we can work on
newData = data.frame(homicideAllData$census_tra, homicideAllData$year, homicideAllData$hournumber, homicideAllData$time,
                     homicideAllData$shooting_count,homicideAllData$wind_speed,homicideAllData$drybulb_fahrenheit,
                     homicideAllData$hourly_precip,homicideAllData$relative_humidity,homicideAllData$dod_drybulb_fahrenheit)
# change column name
colnames(newData) <- c("census_tra", "year","hournumber","time",
                       "shooting_count","wind_speed","drybulb_fahrenheit",
                       "hourly_precip","relative_humidity","dod_drybulb_fahrenheit")


##handle missing data
newData[is.na(newData)] = 0
homicideAllData = na.omit(newData)

### binarize dataset for each column

## binarize humidity
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



## binarize temperature
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



## binaryize wind speed
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




## binarize precipitation.
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



## binarize DOD temperature
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

## create month and day
homicideAllData$month = strftime(homicideAllData$time, "%m")
homicideAllData$day = strftime(homicideAllData$time, "%d")



## factorize all the attributes
## Now this part is comment out because factorize the whole dataset takes too long. We decided to factorize it after
## we subsample it. Maybe in the real computer we can do it here?

#homicideAllData$census_tra = factor(homicideAllData$census_tra)
#homicideAllData$year = factor(homicideAllData$year)
#homicideAllData$hournumber = factor(homicideAllData$hournumber)
#homicideAllData$humidity_index = factor(homicideAllData$humidity_index)
#homicideAllData$temp_index = factor(homicideAllData$temp_index)
#homicideAllData$wind_index = factor(homicideAllData$wind_index)
#homicideAllData$preci_index = factor(homicideAllData$preci_index)
#homicideAllData$dod_index = factor(homicideAllData$dod_index)
#homicideAllData$month = factor(homicideAllData$month)
#homicideAllData$day = factor(homicideAllData$day)
return homicideAllData

}


