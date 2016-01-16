    #How to Run:
    #Rscript updateNN.R [crimeType] [directory to updated data] [directory to base model file] [Index of bagged Samples: {1,2,3,...number of bagged samples}] [number of hidden node] [number of iterations] [datetime of updating]
    #Example: Rscript updateNN.R "robbery_count" $DATAPATH $DATAPATH 1 10 "2015-05-20"

    library(neuralnet)
    library(nnet)

    args <- commandArgs(trailingOnly = TRUE)

    print("======processing input parameters==========")

    if(length(args) != 7){
        print("[Error] Invalid Input Parameters")
        quit()
    }

    ##Specifying the input parameters
    print("======crime type========")
    print(args[1])
    crimeType = args[1]
    
    print("======yvar========")
    print(args[2])
    yvar = args[2]

    print("=====directory to updated data========")
    print(args[3])
    updateDataDir = args[3]

    print("======directory to input model========")
    print(args[4])
    modelDir = args[4]

    print("======Index of Bagged Samples=========") 
    print(args[5])
    indexOfBaggedSamples = as.integer(args[5])

    print("=====Number of Updating Iterations============")
    print(args[6])
    nIter = as.integer(args[6])

    print("====Datetime of updating=============")
    print(args[7])
    dateTime = args[7]


    #load updated training data. The updated training data is the combination of historical bagged data and the updated bagged data
    print("loading historic training data...")
    #trainingData = readRDS(file = paste(updateDataDir, "/.bagTrainingData_", crimeType, "_", indexOfBaggedSamples, ".rds", sep = ""))
    trainingData = read.csv(paste(updateDataDir, "/WeatherandCrime_Data_Iter.", crimeType, ".", indexOfBaggedSamples, ".binned.csv", sep = ""))
    trainingData = data.frame(trainingData)


    print("Done")


    print("loading updated data....")
    #updatedData = readRDS(file = paste(updateDataDir,"/.bagTrainingData_",crimeType,"_Update_",dateTime, "_Index_", indexOfBaggedSamples, ".rds", sep=""))
    #commented out this line bc didn't match up 
    #updatedData = read.csv(paste(updateDataDir,"/WeatherandCrime_Data.",crimeType,"Update.",dateTime, ".", indexOfBaggedSamples, ".binned.csv", sep=""))
    # added to fix above
    updatedData = read.csv(paste(updateDataDir,"/WeatherandCrime_Data", "_Iter", ".", crimeType, ".", indexOfBaggedSamples, ".binned.csv", sep=""))
    updatedData = data.frame(updatedData)
    print("Done")
    print(ncol(trainingData))
    print(ncol(updatedData))

    #Append updated data with the historic training data. And save to historic datas
    trainingData = rbind(trainingData,updatedData)
    print(ncol(trainingData))
    #saveRDS(trainingData,file = paste(updateDataDir, "/.bagTrainingData_", crimeType, "_", indexOfBaggedSamples, ".rds", sep = ""))
    write.csv(trainingData, file = paste(updateDataDir, "/WeatherandCrime_Data.", crimeType, ".", indexOfBaggedSamples, ".binned.csv", sep = ""), row.names=FALSE)

    print("Done")

    ##Prepare the actual data need to be trained.
    names = names(trainingData)
    predictors = trainingData[!names %in% c("shooting_count", "census_tra", "year", "hournumber", "dt", "robbery_count", "assault_count", "hourstart", "wind_speed", "drybulb_fahrenheit", "hourly_precip", "relative_humidity", "dod1_drybulb_fahrenheit", "dod2_drybulb_fahrenheit", "dod3_drybulb_fahrenheit", "wow1_drybulb_fahrenheit", "wow2_drybulb_fahrenheit", "precip_hour_cnt_in_last_1_day", "precip_hour_cnt_in_last_3_day", "precip_hour_cnt_in_last_1_week", "hour_count_since_precip", "month_of_year", "day_of_week")]

    #crimeResponse = trainingData[crimeType]
    crimeResponse = trainingData[yvar]
    trainingData = cbind(crimeResponse, predictors)

    #load trained NN. Filename sample: ._NNmodel_1.rds
    trainedNN = readRDS(file = paste(modelDir,'/',crimeType, "/._NNmodel_", indexOfBaggedSamples, ".rds", sep = "")) 

    #Get the number of hidden nodes of the trained NN
    nHidden = trainedNN$n[2]

    #Get the model formula to prepare to update the new NN.
    #yvarColumnName = c("shooting_count", "robbery_count", "assault_count")
    #names = names(trainingData)
    #f <- as.formula(paste(paste(crimeType," ~"), paste(names[!names %in% crimeTypeColumnName], collapse = " + ")))
    #f <- as.formula(paste(crimeType, paste('~', paste(colnames(trainingData), collapse = '+'))))   
    f <- as.formula(paste(yvar, paste('~', paste(colnames(trainingData), collapse = '+'))))   
    


    #Update NN model; Key trick here it to specify "Wts = trainedNN$wts". This allow us to extract the weight parameter trained in the previous NN and start updating weights from there.
    # Thus, we only need to update the model for a small number of interations instead of running another 200 iterations.

    ir.nn = nnet(f, data = trainingData, size = nHidden, rang = 0.1, MaxNWts = 30000, decay = 5e-4, maxit = nIter, Wts = trainedNN$wts)


    #Save updated model in model directory. Filename sample: ._NNmodel_1_Update_2015-05-21.rds
    print("Saving model.....")
    saveRDS(ir.nn, file = paste(modelDir,'/',crimeType, "/._NNmodel_", crimeType, "_", indexOfBaggedSamples, "_Update_", dateTime, ".rds", sep = ""))

    print(paste("Model_", indexOfBaggedSamples, "Finished Updating on ", dateTime))



    
