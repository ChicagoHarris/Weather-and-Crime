    library(grid)
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
    indexOfBaggedSamples = args[4]

    print("===number of hidden nodes=======")
    print(args[5])
    nHidden = args[5]

    print("======number of iterations=====")
    print(args[6])
    nIter = args[6]

    
    #load training data
    print("loading training data...")

    trainingData = readRDS(file = paste(trainingDataDir, "/.bagTrainingData_",indexOfBaggedSamples,".rds",sep = ""))

    print("Done.")

    #Prepare model formula
    colnames = names(trainingData)
    f <- as.formula(paste(paste(crimeType," ~"), paste(names[!names %in% crimeType], collapse = " + ")))

    #Train NN model
    print("Training model....")
    ir.nn <- nnet(f, data = trainingData, size = nIter, rang = 0.1,MaxNWts = 30000, decay = 5e-4, maxit = nIter)
    
    #Save trained model in model directory
    print("Saving model....")
    saveRDS(ir.nn, file = paste(modelDir,"/._NNmodel_",indexOfBaggedSamples,".rds",sep = ""))

    print(paste("Model",indexOfBaggedSamples,"Finished Training."))


    
