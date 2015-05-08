binarizeData<-function(crimeData,covariates,binningCovariates, numOfBins, crimeType){

crimeData = data.frame(crimeData[,covariates])

##handle missing data
crimeData[is.na(crimeData)] = 0
crimeData = na.omit(crimeData)


allCovariates = c()

for (variates in binningCovariates){
    truncate = crimeData[,variates]
    upperQuan = quantile(truncate, probs = 0.98, names = FALSE)
    lowerQuan = quantile(truncate, probs = 0.02, names = FALSE)
    binBandwidth = (upperQuan - lowerQuan + 0.0001) / numOfBins
    truncate[truncate>upperQuan] = upperQuan
    truncate[truncate<lowerQuan] = lowerQuan
    crimeData[,paste(variates, "index", sep = "_")] = floor((truncate - lowerQuan) / binBandwidth)
}

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



contrastVector = c()
for (variates in processedCovariates){
    #crimeData[,variates] = factor(crimeData[,variates])
    if(variates != crimeType){
    element = paste(variates, '=contrasts(crimeData[,"',variates,'"],contrasts = F)',sep = "")
    contrastVector = c(contrastVector, element)
    }
}




crimeData <- model.matrix( 
  as.formula(paste("~",paste(processedCovariates, collapse = "+"), "-1")),
  data = crimeData,
  as.expression(paste("contrasts.arg=list(", paste(contrastVector,collapse = ","),")",sep = "")))



for (i in c(1:ncol(crimeData))){
  crimeData[,i] = as.integer(crimeData[,i])
}

return(crimeData)
}
