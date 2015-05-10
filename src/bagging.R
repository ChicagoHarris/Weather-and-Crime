
## bagging will subsample from the dataset to get $sampleSize records
bagging<-function(sampleSize, dataSet)
{
  dataSet[sample(nrow(dataSet),sampleSize),]
}
