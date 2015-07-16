    #How to Run:
    #Rscript updateNN.R [crimeType] [directory to updated data] [directory to base model file] [Index of bagged Samples: {1,2,3,...number of bagged samples}] [number of hidden node] [number of iterations] [datetime of updating]
    #Example: Rscript updateNN.R "robbery_count" $DATAPATH $DATAPATH 1 10 "2015-05-20"

    library(neuralnet)
    library(nnet)

    args <- commandArgs(trailingOnly = TRUE)

    print("======processing input parameters==========")

    if(length(args) != 6){
        print("[Error] Invalid Input Parameters")
        quit()
    }

    ##Specifying the input parameters
    print("======crime type========")
    print(args[1])
    crimeType = args[1]

    print("=====directory to updated data========")
    print(args[2])
    updateDataDir = args[2]

    print("======directory to input model========")
    print(args[3])
    modelDir = args[3]

    print("======Index of Bagged Samples=========") 
    print(args[4])
    indexOfBaggedSamples = as.integer(args[4])

    print("=====Number of Updating Iterations============")
    print(args[5])
    nIter = as.integer(args[5])

    print("====Datetime of updating=============")
    print(args[6])
    dateTime = args[6]


    #load updated training data. The updated training data is the combination of historical bagged data and the updated bagged data
    print("loading historic training data...")
    #trainingData = readRDS(file = paste(updateDataDir, "/.bagTrainingData_", crimeType, "_", indexOfBaggedSamples, ".rds", sep = ""))
    trainingData = read.csv(paste(updateDataDir, "/WeatherandCrime_Data.", crimeType, ".", indexOfBaggedSamples, ".binned.csv", sep = ""))
    trainingData = data.frame(trainingData)


    print("Done")


    print("loading updated data....")
    #updatedData = readRDS(file = paste(updateDataDir,"/.bagTrainingData_",crimeType,"_Update_",dateTime, "_Index_", indexOfBaggedSamples, ".rds", sep=""))
    updatedData = read.csv(paste(updateDataDir,"/WeatherandCrime_Data.",crimeType,"Update.",dateTime, ".", indexOfBaggedSamples, ".binned.csv", sep=""))
    updatedData = data.frame(updatedData)
    print("Done")

    #Append updated data with the historic training data. And save to historic datas
    trainingData = rbind(trainingData,updatedData)
    #saveRDS(trainingData,file = paste(updateDataDir, "/.bagTrainingData_", crimeType, "_", indexOfBaggedSamples, ".rds", sep = ""))
    write.table(trainingData, file = paste(updateDataDir, "/WeatherandCrime_Data.", crimeType, ".", indexOfBaggedSamples, ".binned.csv", sep = ""))

    print("Done")

    ##Prepare the actuall data need to be trained.
    names = names(trainingData)
    predictors = trainingData[!names %in% c("shooting_count", "census_tra", "year", "hournumber", "dt", "robbery_count", "assault_count", "hourstart", "wind_speed", "drybulb_fahrenheit", "hourly_precip", "relative_humidity", "dod1_drybulb_fahrenheit", "dod2_drybulb_fahrenheit", "dod3_drybulb_fahrenheit", "wow1_drybulb_fahrenheit", "wow2_drybulb_fahrenheit", "precip_hour_cnt_in_last_1_day", "precip_hour_cnt_in_last_3_day", "precip_hour_cnt_in_last_1_week", "hour_count_since_precip", "month_of_year", "day_of_week")]

    crimeResponse = trainingData[crimeType]
    trainingData = cbind(crimeResponse, predictors)

    #load trained NN. Filename sample: ._NNmodel_1.rds
    trainedNN = readRDS(file = paste(modelDir, "/._NNmodel_", indexOfBaggedSamples, ".rds", sep = ""))
    

    #Get the number of hidden nodes of the trained NN
    nHidden = trainedNN$n[2]

    #Get the model formula to prepare to update the new NN.
    #crimeTypeColumnName = c("shooting_count", "robbery_count", "assault_count")
    #names = names(trainingData)
    #f <- as.formula(paste(paste(crimeType," ~"), paste(names[!names %in% crimeTypeColumnName], collapse = " + ")))
    #Here trainingData[2:1113] is selected based on Maggie's testNN.R; Need to be careful about this hardcoded index of columns
    f <- as.formula(paste(crimeType, paste('~', paste(colnames(trainingData), collapse = '+'))))   



    #Update NN model; Key trick here it to specify "Wts = trainedNN$wts". This allow us to extract the weight parameter trained in the previous NN and start updating weights from there.
    # Thus, we only need to update the model for a small number of interations instead of running another 200 iterations.

    ir.nn = nnet(f, data = trainingData, size = nHidden, rang = 0.1, MaxNWts = 30000, decay = 5e-4, maxit = nIter, Wts = trainedNN$wts)


    #Save updated model in model directory. Filename sample: ._NNmodel_1_Update_2015-05-21.rds
    print("Saving model.....")
    saveRDS(ir.nn, file = paste(modelDir, "/._NNmodel_", crimeType, "_", indexOfBaggedSamples, "_Update_", dateTime, ".rds", sep = ""))

    print(paste("Model_", indexOfBaggedSamples, "Finished Updating on ", dateTime))



    
