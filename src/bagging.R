bagging<-function(sampleSize, dataSet)
{
  dataSet[sample(nrow(dataSet),sampleSize),]
}
