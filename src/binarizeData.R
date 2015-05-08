binarizeData<-function(crimeData, forecastData, covariates,binningCovariates, modelCovariates, numOfBins, crimeType, numOfBaggedSamples){
    library(parallel)

    crimeData = crimeData[,covariates]
    forecastData = forecastData[,covariates]

    processedCovariates = modelCovariates$processedCovariates
    allCovariates = modelCovariates$allCovariates

    #Record the upper bound and lower bound for a certain variable in historical data
    #We need that to truncate the testing data.

    upperQuanVector = c()
    lowerQuanVector = c()
    
    print("Binning historical data....")
    #Binning the historical data
    #Record the upper bound and lower bound

    for (variates in binningCovariates){

        truncate = crimeData[,variates]

        upperQuan = quantile(truncate, probs = 0.98, names = FALSE)
        upperQuanVector = c(upperQuanVector, upperQuan)
        lowerQuan = quantile(truncate, probs = 0.02, names = FALSE)
        lowerQuanVector = c(lowerQuanVector, lowerQuan)

        binBandwidth = (upperQuan - lowerQuan + 0.0001) / numOfBins
        truncate[truncate>upperQuan] = upperQuan
        truncate[truncate<lowerQuan] = lowerQuan
        crimeData[,paste(variates, "index", sep = "_")] = floor((truncate - lowerQuan) / binBandwidth)
    }
    print("Done.")


    print("Binning forecast data.....")

    #Binning the forecast data

    for (i in c(1:length(binningCovariates))){
        variates = binningCovariates[i]
        truncate = forecastData[,variates]
        truncate[truncate>upperQuanVector[i]] = upperQuanVector[i]
        truncate[truncate<lowerQuanVector[i]] = lowerQuanVector[i]

        binBandwidth = (upperQuanVector[i] - lowerQuanVector[i] + 0.0001) / numOfBins
        forecastData[,paste(variates, "index", sep = "_")] = floor((truncate - lowerQuanVector[i]) / binBandwidth)
    }

    print("Done.")

    # bagging and binaralize



    # binaralize forecast data

    print("binaralize forecast data....")
    contrastVector = c()
    for (variates in processedCovariates){
        if(variates != crimeType){
        forecastData[,variates] = factor(forecastData[,variates])
        element = paste(variates, '=contrasts(forecastData[,"',variates,'"],contrasts = F)',sep = "")
        contrastVector = c(contrastVector, element)
        }
    }

    forecastData <- model.matrix( 
      as.formula(paste("~",paste(processedCovariates, collapse = "+"), "-1")),
      data = forecastData,
      as.expression(paste("contrasts.arg=list(", paste(contrastVector,collapse = ","),")",sep = "")))

    forecastData = data.frame(forecastData)

    #In case some covariates are missing in the forecase data, we manually add it back in.
    for (variates in allCovariates){
        if(!variates %in% colnames(forecastData)){
            forecastData[,variates] = 0
        }
    }

    for (i in c(1:ncol(forecastData))){
      forecastData[,i] = as.integer(forecastData[,i])
    }

    print("Done.")
    # binaralize historical crime data


    print("Preparing Positive and Negative Historical Data....")

    positveCrimeData = crimeData[crimeData[,crimeType]>0,]
    negativeCrimeData = crimeData[crimeData[,crimeType] == 0,]

    print("Done.")

    bagAndBinaralizeTraining<-function(i){

        baggedNegativeCrimeData = bagging(nrow(positveCrimeData),negativeCrimeData)

        crimeData = rbind(baggedNegativeCrimeData,positveCrimeData)    

        contrastVector = c()
        for (variates in processedCovariates){
            if(variates != crimeType){
            crimeData[,variates] = factor(crimeData[,variates])
            element = paste(variates, '=contrasts(crimeData[,"',variates,'"],contrasts = F)',sep = "")
            contrastVector = c(contrastVector, element)
            }
        }

        crimeData <- model.matrix( 
          as.formula(paste("~",paste(processedCovariates, collapse = "+"), "-1")),
          data = crimeData,
          as.expression(paste("contrasts.arg=list(", paste(contrastVector,collapse = ","),")",sep = "")))

        crimeData = data.frame(crimeData)
        
        #In case some covariates are missing in the forecase data, we manually add it back in.
        for (variates in allCovariates){
            if(!variates %in% colnames(crimeData)){
                crimeData[,variates] = 0
            }
        }
        
        for (i in c(1:ncol(crimeData))){
          crimeData[,i] = as.integer(crimeData[,i])
        }
        crimeData
    }

    print("Parallelize Binaralizing Bagged Training Data....")
    bagOfTraining = mclapply(c(1:numOfBaggedSamples), bagAndBinaralizeTraining) 

    print("Done")
    result = list("bagOfTraining" = bagOfTraining, "forecastData" = forecastData)

}
