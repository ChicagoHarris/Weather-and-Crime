    library(neuralnet)
    library(nnet)

    #process arguments passed into the script
    args <- commandArgs(trailingOnly = TRUE)

    print("===processing input parameters====")

    if(length(args) != 6){
        print("[Error] Invalid Input Parameters")
        quit()
    }

    print("=========crime type=============")
    print(args[1])
    crimeType = args[1]

    print("===directory to input training data===")
    print(args[2])
    trainingDataDir = args[2]

    print("===directory to output model=======")
    print(args[3])
    modelDir = args[3]

    print("======Index of Bagged Samples=====")
    print(args[4])
    indexOfBaggedSamples = as.integer(args[4])

    print("===number of hidden nodes=======")
    print(args[5])
    nHidden = as.integer(args[5])

    print("======number of iterations=====")
    print(args[6])
    nIter = as.integer(args[6])

    
    #load training data
    print("loading training data...")

    trainingData = readRDS(file = paste(trainingDataDir, "/.bagTrainingData_", crimeType, "_", indexOfBaggedSamples,".rds",sep = ""))

    print("Done.")

    #Prepare model formula
    crimeTypeColumnName = c("shooting_count", "robbery_count", "assault_count")
    names = names(trainingData)
    f <- as.formula(paste(paste(crimeType," ~"), paste(names[!names %in% crimeTypeColumnName], collapse = " + ")))

    #Train NN model
    print("Training model....")
    ir.nn <- nnet(f, data = trainingData, size = nHidden, rang = 0.1,MaxNWts = 30000, decay = 5e-4, maxit = nIter)
    
    #Save trained model in model directory
    print("Saving model....")
    saveRDS(ir.nn, file = paste(modelDir,"/._NNmodel_",crimeType, "_", indexOfBaggedSamples,".rds",sep = ""))

    print(paste("Model",indexOfBaggedSamples,"Finished Training."))


    
