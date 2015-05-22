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
    print("loading training data...")
    trainingData = readRDS(file = paste(updateDataDir, "/.bagTrainingData_", indexOfBaggedSamples, ".rds", sep = ""))

    print("Done")

    #load trained NN. Filename sample: ._NNmodel_1.rds
    trainedNN = readRDS(file = paste(modelDir, "/._NNmodel_", indexOfBaggedSamples, ".rds", sep = ""))
    

    #Get the number of hidden nodes of the trained NN
    nHidden = trainedNN$n[2]

    #Get the model formula to prepare to update the new NN.
    crimeTypeColumnName = c("shooting_count", "robbery_count", "assault_count")
    names = names(trainingData)
    f <- as.formula(paste(paste(crimeType," ~"), paste(names[!names %in% crimeTypeColumnName], collapse = " + ")))
    


    #Update NN model; Key trick here it to specify "Wts = trainedNN$wts". This allow us to extract the weight parameter trained in the previous NN and start updating weights from there.
    # Thus, we only need to update the model for a small number of interations instead of running another 200 iterations.

    ir.nn = nnet(f, data = trainingData, size = nHidden, rang = 0.1, MaxNWts = 30000, decay = 5e-4, maxit = nIter, Wts = trainedNN$wts)


    #Save updated model in model directory. Filename sample: ._NNmodel_1_Update_2015-05-21.rds
    print("Saving model.....")
    saveRDS(ir.nn, file = paste(modelDir, "/._NNmodel_", indexOfBaggedSamples, "_Update_", dateTime, ".rds", sep = ""))

    print(paste("Model_", indexOfBaggedSamples, "Finished Updating on ", dateTime))



    
