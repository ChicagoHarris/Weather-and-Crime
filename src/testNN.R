    library(neuralnet)
    library(nnet)

    #process arguments passed into the script
    args <- commandArgs(trailingOnly = TRUE)

    print("===processing input parameters====")

    if(length(args) != 5){
        print("[Error] Invalid Input Parameters")
        quit()
    }

    print("=========crime type=============")
    print(args[1])
    crimeType = args[1]

    print("===directory to input testing data===")
    print(args[2])
    testingDataDir = args[2]

    print("===directory to input model=======")
    print(args[3])
    modelDir = args[3]

    print("===directory to output prediction=======")
    print(args[4])
    predictionDir = args[4]
    

    print("======number of Bagged Samples=====")
    print(args[5])
    numOfBaggedSamples = as.integer(args[5])
    

    #load testing data
    print("loading testing data")

    testingData = readRDS(file = paste(testingDataDir,"/.testingData.rds",sep = ""))

    print("Done.")
    
    #load original forecast data
    print("loading original forecast data")
    forecastData = readRDS(file = paste(testingDataDir,"/.originalForecastData.rds",sep = ""))
    print("Done.")


    #Create a new column to hold all the predictions
    forecastData$prediction = 0

    #Making prediciton using different Neural net


    print("Start predicting....")

    for (i in c(1:numOfBaggedSamples)){
        print(paste("processing NN prediciton No.",i))
        trainedNN = readRDS(file = paste(modelDir, "/._NNmodel_", i, ".rds", sep = ""))
        predictedResult = predict(trainedNN, testingData,type = "raw")
        forecastData$prediction = forecastData$prediction + predictedResult
    }
    
    #Average all different predictions
    forecastData$prediction = forecastData$prediction/ numOfBaggedSamples
    forecastData$predictionBinary = forecastData$prediction
    forecastData$predictionBinary[forecastData$prediction>=0.5] = 1
    forecastData$predictionBinary[forecastData$prediction<0.5] = 0
    
    print("Done.")

    print("Saving prediction file...")

    #Save prediction to csv file
    write.csv(forecastData, file = paste(predictionDir,"/prediction.csv",sep = ""),row.names = FALSE)
    print("Done.") 
