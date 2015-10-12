createCovariates<-function(crimeData, covariates, binningCovariates, numOfBins, crimeType){

#Process covariates
#processedCovariates: name of covariates after binning
#allCovariates: name of covariates after binning and binarizing

processedCovariates = covariates
allCovariates = c()

for (i in c(1:length(processedCovariates))){
    if (covariates[i] %in% binningCovariates){
        processedCovariates[i] = paste(covariates[i], "index", sep = "_")
        for (j in c(1:numOfBins)){
            allCovariates = c(allCovariates, paste(processedCovariates[i],j,sep = ""))
        }
    }
    else if(covariates[i] != crimeType){
        processedCovariates[i] = covariates[i]
        for (j in unique(crimeData[,covariates[i]])){
            allCovariates = c(allCovariates, paste(processedCovariates[i],j,sep = ""))
        }
    }
    else{
        allCovariates = c(allCovariates, crimeType)
        processedCovariates[i] = crimeType
    }
}

resultCovariate = list("processedCovariates" = processedCovariates, "allCovariates" = allCovariates)

resultCovariate

}
