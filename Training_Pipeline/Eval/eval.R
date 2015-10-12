#R script for evaluating results from prediction.csv 
### FOR APPENDING TO EXISTING EVAL.R 

#library(ROCR)

# Set wd
setwd("/Users/maggieking/Documents/WeatherandCrime/predictions")  
data <- read.csv("shooting_prediction1to100.csv")
orig = data
data$true_crime = data[,4]
data<- subset(data, !is.na(prediction))



#for summary by stats only

calc_tpr <- function(data) {
  #Create TP and TN rates
  tp <- ifelse((data$true_crime == 1 & data$predictionBinary == 1), 1, 0)
  fn = ifelse((data$true_crime ==1 & data$predictionBinary==0), 1, 0)
  tp_sum = sum(tp)
  fn_sum = sum(fn)
  # Calculate Sensitivity (aka recall aka TPR)
  trueposrate <- tp_sum/(tp_sum + fn_sum)
  data$tpr <- trueposrate
}


calc_tnr <- function(data) {
  #Create TP and TN rates
  tn = ifelse((data$true_crime == 0 & data$predictionBinary == 0), 1, 0)
  fp = ifelse((data$true_crime ==0 & data$predictionBinary ==1),1, 0)
  tn_sum = sum(tn)
  fp_sum = sum(fp)
  # Calculate Specificity (aka TNR)
  data$tnr = tn_sum/(tn_sum + fp_sum)
}

calc_acc <- function(data) {
  #Create TP and TN rates
  tp <- ifelse((data$true_crime == 1 & data$predictionBinary == 1), 1, 0)
  tn <- ifelse((data$true_crime == 0 & data$predictionBinary == 0), 1, 0)
  tp_sum = sum(tp)
  tn_sum = sum(tn)
  #Accuracy
  data$acc = (tp_sum + tn_sum) / (nrow(data))
}

# Calc success by hour 
hour_number_list = seq(0,23)
success_by_hour <- function(hour) {
  hour_data <- subset(data, data$hournumber == hour)
  tpr = calc_tpr(hour_data)
  tnr = calc_tnr(hour_data)
  acc = calc_acc(hour_data)
  success = c(hour=hour,tpr=tpr,tnr=tnr,acc=acc)
  return(success)
}
all_successes_hour <- lapply(hour_number_list, success_by_hour)
data_hour <- data.frame(t(sapply(all_successes_hour,c)))

# Calc success by tract
tracts_number_list <- unique(data$census_tra)
success_by_tract <- function(tracts) {
  census_data <- subset(data, data$census_tra == tracts)
  tpr = calc_tpr(census_data)
  tnr = calc_tnr(census_data)
  acc = calc_acc(census_data)
  success = c(tracts=tracts,tpr=tpr,tnr=tnr,acc=acc)
  return(success)
}
all_successes_tracts <- lapply(tracts_number_list, success_by_tract)
data_tract <- data.frame(t(sapply(all_successes_tracts,c)))
data_tract$census_tract <- data_tract[,1]
data_tract$tpr <- data_tract[,2]
data_tract$tnr <- data_tract[,3]
data_tract$acc <- data_tract[,4]


# Clock: Plot Success over the source of a day
plot(tpr~hour, data=data_hour, main = "True Positive Rate by Hour, Violent Crimes")
plot(tnr~hour, data=data_hour, main = "True Negative Rate by Hour, Violent Crimes")
plot(acc~hour, data=data_hour, main = "Accuracy by Hour, Violent Crimes")


# Run AFTER calculating performance metrics by tract, so that you are able to compare to results created below. 
data = data_tract
# Calculate "Most Violent Tracts" by summing # crimes per tract in entire sample
sum_crime_by_tract <- aggregate(data$true_crime, by = list(data$census_tra), FUN = sum)
violence_sum <- sum_crime_by_tract$x
tract_again <- sum_crime_by_tract$Group.1
data$violence_sum <- violence_sum

# Performance of model in most violent tracts v least violent tracts:
# Order tracts from most violent to least violent (Not necessary, but useful for visualizing/scanning results)
data <- data[order(-data$violence_sum),]
high_violence <- ifelse((data$violence_sum > (mean(data$violence_sum))), 1, 0)   # maybe be stricter than mean
high_violence_and_high_acc <- ifelse((high_violence==1 & data$acc>0.6), 1, 0)
high_violence_and_high_tpr <- ifelse((high_violence==1 & data$tpr>0.6), 1, 0)
high_violence_and_high_tnr <- ifelse((high_violence==1 & data$tnr>0.6), 1, 0)


# Are we suggesting expending more resources than we reasonably expect we are spending at present?
data <- data[order(-data$prediction),]
head(data)
min(data$violence_sum)
max(data$violence_sum)
mean(data$violence_sum)
# No, if the tracts ranked near the top are also near to the max in data$violence_sum
# yes, if tracts ranked near the top are near to or less than the mean in data$violence_sum.
#
# Are we suggesting expending more resources in new tracts ie tracts that are not obviously policed? 
tail(data)
# Compare violence sums to prediction. If prediction is higher in the lower ranked cells on violence_sum, then 
# these areas have the potential to be hot spots that are not obvious. 
#
head(data)
# Compare violence_sums to prediction. If prediction is lower in highly ranked cells on violence_sum, then 
# these areas have the potential to be over policed by aggregate metrics. 
# Define tracts that are likely policed based on count of crimes over time (data$violence_sum)
mean(data$violence_sum)
likely_policed <- ifelse((data$violence_sum > (mean(data$violence_sum))), 1, 0)   # maybe be stricter than mean
head(likely_policed)
# Compare high policed tracts to tracts that are high risk tracts.
high_risk_and_likely_policed <- ifelse((likely_policed==1 & data$prediction>0.5), 1, 0)
crimes_hit <- sum(data$true_crime[which(high_risk_and_likely_policed==1)])
100*(crimes_hit/(sum(data$true_crime)))
# Or are we just innaccurate on these tracts, and missing something important? 
#
# How effective is a predictive strategy relative to aggregate historical crime based strategy for distributing policing? 
crimes_hit_cpd_method <- sum(data$true_crime[which(likely_policed==1)])
crimes_hit_our_method <- sum(data$true_crime[which(data$prediction>0.5)])
# what percentage of crimes does each of this method "catch"?
100*(crimes_hit_cpd_method/(sum(data$true_crime)))
100*(crimes_hit_our_method/(sum(data$true_crime)))



#ignore
#find other problem rows if necessary
which(orig$census_tra == "26 15:00:00")
remove_list <- c(2692245)
data <- data[-remove_list,]
head(data)

#data_62800 <- subset(data, data$census_tra == 62800)
#data_62800$tpr <- calc_tpr(data_62800)
data_hour_0 <- subset(data, data$hournumber == 0)
data_hour_0_success <- calc_tpr(data_hour_0)
data_hour_0_success

#HOURS
hours <- unique(data$hournumber)
data_hours <- data.frame(hours)
data_hours$tpr <- NA
data_hours$tnr <- NA
data_hours$acc <- NA


# By tract
success_by_tract <- function(data) {
  #Create vectors for each success metric
  data$tpr <- NA
  data$tnr <- NA
  data$acc <- NA
  #Create a list of census tracts 
  census_list <- split(data, f = data$census_tra)
  tprate <- mapply(calc_tpr, census_list[census_list != "26 15:00:00"])
  #tnr <- mapply(calc_tnr, census_list)
  #acc <- mapply(calc_acc, census_list)
  data$tpr <- tprate
  #data$tnr <- tnr
  #data$acc <- acc
  return(data)
}
data <- success_by_tract(data)
head(data_tract)


write.table(data_tract, file="shooting_pred_success_bytract.csv", row.names=FALSE, col.names=TRUE, sep=",")
write.table(data_hour, file="shooting_pred_success_byhour.csv", row.names=FALSE, col.names=TRUE, sep=",")


