    library(neuralnet)
    library(nnet)

    args <- commandArgs(trailingOnly = TRUE)

    print("======processing input parameters==========")

    if(length(args) != 6){
        print("[Error] Invalid Input Parameters")
        quit()
    }

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

    print("=====Number of Iterations============")
    print(args[5])
    nIter = as.integer(args[5])

    print("====Datetime of updating=============")
    print(args[6])
    dateTime = args[6]


    #load updated training data
    print("loading training data...")
    trainingData = readRDS(file = paste(updateDataDir, "/.bagTrainingData_", indexOfBaggedSamples, ".rds", sep = ""))

    print("Done")

    #load trained NN
    trainedNN = readRDS(file = paste(modelDir, "/._NNmodel_", indexOfBaggedSamples, ".rds", sep = ""))
    
    nHidden = trainedNN$n[2]
    crimeTypeColumnName = c("shooting_count", "robbery_count", "assault_count")
    names = names(trainingData)
    f <- as.formula(paste(paste(crimeType," ~"), paste(names[!names %in% crimeTypeColumnName], collapse = " + ")))
    
    #Update NN model

    ir.nn = nnet(f, data = trainingData, size = nHidden, rang = 0.1, MaxNWts = 30000, decay = 5e-4, maxit = nIter, Wts = trainedNN$wts)


    #Save trained model in model directory
    print("Saving model.....")
    saveRDS(ir.nn, file = paste(modelDir, "/._NNmodel_", indexOfBaggedSamples, "_Update_", dateTime, ".rds", sep = ""))

    print(paste("Model_", indexOfBaggedSamples, "Finished Updating on ", dateTime))



    
