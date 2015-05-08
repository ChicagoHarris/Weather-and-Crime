
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
    numOfBins = as.integer(args[2])

    print("======Number of bagged samples=========")
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

    # load the raw data
    print("loading csv ...(This gonna take a long time)")
    crimeData = read.csv(rawDataDir)

    # create time as Type time
    crimeData$time = as.POSIXct(crimeData$hourstart, format="%Y-%m-%d %H:%M:%S")
    crimeData$month = strftime(crimeData$time, "%m")
    crimeData$day = strftime(crimeData$time, "%d")

    print("finish loading")


    print("Preparing.....")

    # specify all the covariates we will use to model
    dataCovariates = c("census_tra", "month","day","hournumber", crimeType, "wind_speed", "drybulb_fahrenheit", "hourly_precip", "relative_humidity", "dod_drybulb_fahrenheit")

    # specify the variables that we will binning
    binningCovariates = c("wind_speed","drybulb_fahrenheit","hourly_precip","relative_humidity","dod_drybulb_fahrenheit")


    crimeData = crimeData[,c(covariates,"time")]

    ##handle missing data
    crimeData[is.na(crimeData)] = 0
    crimeData = na.omit(crimeData)

    # create the covariates after binning and binarizing
    modelCovariates = createCovariates(crimeData, dataCovariates, binningCovariates, numOfBins, crimeType)


    #For now, we manually separate raw data into training data and testing data
    # training data: 2009-2013
    # testing data: 2014
    # In the future, training data and testing data will be loaded from separate places.
    historicalData = crimeData[which(crimeData$time < as.POSIXct("2014-01-01", format="%Y-%m-%d")
                               & crimeData$time >= as.POSIXct("2009-01-01", format="%Y-%m-%d")),]
    forecastData = crimeData[which(crimeData$time >= as.POSIXct("2014-01-01", format="%Y-%m-%d")),]


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

    saveRDS(data.frame(processedData$forecastData, file = paste(testingDataDir, "/.testingData.rds", sep = "")))
    

    #Save forecast data for furthur evaluation
    saveRDS(data.frame(forecastData), file = paste(testingDataDir, "/.originalForecastData.rds", sep = ""))


    print("Data preprocessing done!")



