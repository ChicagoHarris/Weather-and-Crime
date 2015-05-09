
    source("bagging.R")
    source("binarizeData.R")
    source("createCovariates.R")

    #process arguments passed into the script
    args <- commandArgs(trailingOnly = TRUE)
    print("====Processing Input Parameters====")
    if(length(args)!=6){
        print("[Error] Invalid Input Parameters")
        quit()
    }
    print("=========crime type==================")
    print(args[1])
    crimeType = args[1]

    print("====Number of bins for continous variable==")
    print(args[2])
    numOfBins = as.integer(args[2])

    print("======Number of bagged samples=========")
    print(args[3])
    numOfBaggedSamples = as.integer(args[3])

    print("========directory to raw data=========")
    print(args[4])
    rawDataDir = args[4]

    print("====directory to output training data====")
    print(args[5])
    trainingDataDir = args[5]

    print("=====directory to output testing data=======")
    print(args[6])
    testingDataDir = args[6]


    # set maximum number of test points. Otherwise we will have memory problem
    MAXROW = 1000000


    # load the raw data
    print("loading csv ...(This gonna take a long time)")
    crimeData = read.csv(rawDataDir)
    crimeData = data.frame(crimeData)

    # create time as Type time
    crimeData$time = as.POSIXct(crimeData$hourstart, format="%Y-%m-%d %H:%M:%S")
    crimeData$month = strftime(crimeData$time, "%m")
    crimeData$day = strftime(crimeData$time, "%d")

    print("finish loading")


    print("Preparing.....")

    # specify all the covariates we will use to model
    dataCovariates = c("census_tra", "month","day","hournumber", crimeType, "wind_speed", 
    "drybulb_fahrenheit", "hourly_precip", "relative_humidity", 
    "dod1_drybulb_fahrenheit","dod2_drybulb_fahrenheit","dod3_drybulb_fahrenheit",
    "wow1_drybulb_fahrenheit","wow2_drybulb_fahrenheit","precip_hour_cnt_in_last_1_day",
    "precip_hour_cnt_in_last_3_day","precip_hour_cnt_in_last_1_week","hour_count_since_precip")

    # specify the variables that we will binning
    binningCovariates = c("wind_speed","drybulb_fahrenheit","hourly_precip","relative_humidity",
    "dod1_drybulb_fahrenheit","dod2_drybulb_fahrenheit","dod3_drybulb_fahrenheit",
    "wow1_drybulb_fahrenheit","wow2_drybulb_fahrenheit","precip_hour_cnt_in_last_1_day",
    "precip_hour_cnt_in_last_3_day","precip_hour_cnt_in_last_1_week","hour_count_since_precip")


    crimeData = crimeData[,c(dataCovariates,"year")]

    ##handle missing data
    crimeData[is.na(crimeData)] = 0
    crimeData = na.omit(crimeData)

    # create the covariates after binning and binarizing
    modelCovariates = createCovariates(crimeData, dataCovariates, binningCovariates, numOfBins, crimeType)


    #For now, we manually separate raw data into training data and testing data
    # training data: 2009-2013
    # testing data: 2014
    # In the future, training data and testing data will be loaded from separate places.
    historicalData = crimeData[which(crimeData$year < 2014
                               & crimeData$year >= 2009),]
    forecastData = crimeData[which(crimeData$year >= 2014),]

    
    #Test if test data has more than MAXROW records. This should never happen in reality since we wont
    #predict so many points.

    if(nrow(forecastData) > MAXROW){
        print(paste("WARNING: Forecast data has more records than", MAXROW))
        print(paste("Using first", MAXROW, "rows instead"))
        forecastData = forecastData[1:MAXROW,]
    }


    print("Binning, binaralizing and bagging data.....")
    
    #binarize training and testing data
    #Notice that binarization takes lots of memory, we bag training data as well
    processedData = binarizeData(historicalData, forecastData, dataCovariates, binningCovariates, modelCovariates, numOfBins, crimeType, numOfBaggedSamples)
    
    print("Save preprocessed data into directory.....")


    ##Save bags of training data to trainingDataDir
    for (i in c(1:numOfBaggedSamples)){
        saveRDS(data.frame(processedData$bagOfTraining[i]), file = paste(trainingDataDir,"/.bagTrainingData_",i,".rds",sep = ""))

    }

    ##Save testing data to testingDataDir

    saveRDS(data.frame(processedData$forecastData), file = paste(testingDataDir, "/.testingData.rds", sep = ""))
    

    #Save forecast data for furthur evaluation
    saveRDS(data.frame(forecastData), file = paste(testingDataDir, "/.originalForecastData.rds", sep = ""))


    print("Data preprocessing done!")



