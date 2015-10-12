setwd("/Users/maggieking/Documents/WeatherandCrime/predictions")

violent <- read.csv("shooting_prediction1to100.csv")
assault <- read.csv("assault_prediction1to100.csv")
robbery <- read.csv("robbery_prediction1to100.csv")

head(violent)

gen_acc <- function(data) {
  data$true_crime = data[,4]
  data$predictionBinary = ifelse((data[,5]>0.5), 1, 0)
  #data<- subset(data, !is.na(prediction))
  head(data)
  
  #Create TP and TN rates
  data$tp <- ifelse((data$true_crime == 1 & data$predictionBinary == 1), 1, 0)
  data$tn = ifelse((data$true_crime == 0 & data$predictionBinary == 0), 1, 0)
  data$fp = ifelse((data$true_crime ==0 & data$predictionBinary ==1),1, 0)
  data$fn = ifelse((data$true_crime ==1 & data$predictionBinary==0), 1, 0)
  tp_sum = sum(data$tp)
  tn_sum = sum(data$tn)
  fp_sum = sum(data$fp)
  fn_sum = sum(data$fn)
  
  # Calculate Sensitivity (aka recall aka TPR)
  tpr = tp_sum/(tp_sum + fn_sum)
  
  # Calculate Specificity (aka TNR)
  tnr = tn_sum/(tn_sum + fp_sum)
  
  # Calculate False Positive Rate (FPR)
  fpr = 1 - tnr
  
  #Accuracy
  acc = (tp_sum + tn_sum) / (nrow(data))
  
  print(paste0("TPR:", tpr))
  print(paste0("TNR:", tnr))
  print(paste0("FPR:", fpr))
  print(paste0("ACCURACY:", acc))  
}

gen_acc(data)

gen_buckets <- function(data) {
  data$prediction = data$shooting_count_y
  data$to_10 <- ifelse((data$prediction >=0 & data$prediction <= 0.10), data$prediction, NA)
  data$to_20 <- ifelse((data$prediction >0.10 & data$prediction <= 0.20), data$prediction, NA)
  data$to_30 <- ifelse((data$prediction >0.20 & data$prediction <= 0.30), data$prediction, NA)
  data$to_40 <- ifelse((data$prediction >0.30 & data$prediction <= 0.40), data$prediction, NA)
  data$to_50 <- ifelse((data$prediction >0.40 & data$prediction <= 0.50), data$prediction, NA)
  data$to_60 <- ifelse((data$prediction >0.50 & data$prediction <= 0.60), data$prediction, NA)
  data$to_70 <- ifelse((data$prediction >0.60 & data$prediction <= 0.70), data$prediction, NA)
  data$to_80 <- ifelse((data$prediction >0.70 & data$prediction <= 0.80), data$prediction, NA)
  data$to_90 <- ifelse((data$prediction >0.80 & data$prediction <= 0.90), data$prediction, NA)
  data$to_100 <- ifelse((data$prediction >0.90 & data$prediction <= 1), data$prediction, NA)
  
  print(mean(data$to_10, na.rm=TRUE))  
  print(mean(data$to_20, na.rm=TRUE))  
  print(mean(data$to_30, na.rm=TRUE))  
  print(mean(data$to_40, na.rm=TRUE))  
  print(mean(data$to_50, na.rm=TRUE))  
  print(mean(data$to_60, na.rm=TRUE))  
  print(mean(data$to_70, na.rm=TRUE))  
  print(mean(data$to_80, na.rm=TRUE))  
  print(mean(data$to_90, na.rm=TRUE))  
  print(mean(data$to_100, na.rm=TRUE))  
  
}

gen_buckets(data)

gen_bucket_truecounts <- function(data) {
  data$true_crime = data[,4]
  data$prediction = data$shooting_count_y
  #data<- subset(data, !is.na(prediction))
  data$to_10 <- ifelse((data$prediction >=0 & data$prediction <= 0.10), data$true_crime, NA)
  data$to_20 <- ifelse((data$prediction >0.10 & data$prediction <= 0.20), data$true_crime, NA)
  data$to_30 <- ifelse((data$prediction >0.20 & data$prediction <= 0.30), data$true_crime, NA)
  data$to_40 <- ifelse((data$prediction >0.30 & data$prediction <= 0.40), data$true_crime, NA)
  data$to_50 <- ifelse((data$prediction >0.40 & data$prediction <= 0.50), data$true_crime, NA)
  data$to_60 <- ifelse((data$prediction >0.50 & data$prediction <= 0.60), data$true_crime, NA)
  data$to_70 <- ifelse((data$prediction >0.60 & data$prediction <= 0.70), data$true_crime, NA)
  data$to_80 <- ifelse((data$prediction >0.70 & data$prediction <= 0.80), data$true_crime, NA)
  data$to_90 <- ifelse((data$prediction >0.80 & data$prediction <= 0.90), data$true_crime, NA)
  data$to_100 <- ifelse((data$prediction >0.90 & data$prediction <= 1), data$true_crime, NA)
  
  print(sum(data$to_10, na.rm=TRUE))  
  print(sum(data$to_20, na.rm=TRUE))  
  print(sum(data$to_30, na.rm=TRUE))  
  print(sum(data$to_40, na.rm=TRUE))  
  print(sum(data$to_50, na.rm=TRUE))  
  print(sum(data$to_60, na.rm=TRUE))  
  print(sum(data$to_70, na.rm=TRUE))  
  print(sum(data$to_80, na.rm=TRUE))  
  print(sum(data$to_90, na.rm=TRUE))  
  print(sum(data$to_100, na.rm=TRUE))  
  
}

gen_bucket_truecounts(data)


gen_bucket_allcounts <- function(data) {
  data$true_crime = data[,4]
  data$prediction = data$shooting_count_y
  #data<- subset(data, !is.na(prediction))
  data$to_10 <- ifelse((data$prediction >=0 & data$prediction <= 0.10), 1, NA)
  data$to_20 <- ifelse((data$prediction >0.10 & data$prediction <= 0.20), 1, NA)
  data$to_30 <- ifelse((data$prediction >0.20 & data$prediction <= 0.30), 1, NA)
  data$to_40 <- ifelse((data$prediction >0.30 & data$prediction <= 0.40), 1, NA)
  data$to_50 <- ifelse((data$prediction >0.40 & data$prediction <= 0.50), 1, NA)
  data$to_60 <- ifelse((data$prediction >0.50 & data$prediction <= 0.60), 1, NA)
  data$to_70 <- ifelse((data$prediction >0.60 & data$prediction <= 0.70), 1, NA)
  data$to_80 <- ifelse((data$prediction >0.70 & data$prediction <= 0.80), 1, NA)
  data$to_90 <- ifelse((data$prediction >0.80 & data$prediction <= 0.90), 1, NA)
  data$to_100 <- ifelse((data$prediction >0.90 & data$prediction <= 1), 1, NA)
  
  print(sum(data$to_10, na.rm=TRUE))  
  print(sum(data$to_20, na.rm=TRUE))  
  print(sum(data$to_30, na.rm=TRUE))  
  print(sum(data$to_40, na.rm=TRUE))  
  print(sum(data$to_50, na.rm=TRUE))  
  print(sum(data$to_60, na.rm=TRUE))  
  print(sum(data$to_70, na.rm=TRUE))  
  print(sum(data$to_80, na.rm=TRUE))  
  print(sum(data$to_90, na.rm=TRUE))  
  print(sum(data$to_100, na.rm=TRUE))  
  
}

gen_bucket_allcounts(data)

library(ggplot2)
library(ggmap)
library(maps)
library(mapproj)
library(mapdata)
library(sp)
library(maptools)
library(rgeos)
library(geosphere)
#map
#with Google maps on the background
lng.center = -87.6297982
lat.center = 41.8781136
gm10<- ggmap(get_googlemap(center=c(lng.center,lat.center), zoom=10, maptype='roadmap'))
gm11<- ggmap(get_googlemap(center=c(lng.center,lat.center), zoom=11, maptype='roadmap'))

coords <- read.csv("/Users/maggieking/Documents/WeatherandCrime/Weather-and-Crime/deprecated/Data/censusTractGrouping.csv")

newdata <- merge(coords, data, by = "census_tra")
head(newdata)


## All hours
map_tpvfn <- function(newdata) {
  tp <- subset(newdata, tp==1)
  tn <- subset(newdata, tn==1)
  fp <- subset(newdata, fp==1)
  fn <- subset(newdata, fn==1)
  #gm11 + geom_point(data=tp, aes(x=lon, y=lat, colour="black")) 
  #gm11 + geom_point(data=fn, aes(x=lon, y=lat, colour="#000099")) 
  fn_map <- gm11 + geom_point(data=fn, aes(x=lon, y=lat, colour="#000099"))
  fn_map + geom_point(data=tp, aes(x=lon, y=lat, colour="#CC0000")) 
}
map_tpvfn(newdata)

map_fpvtp <- function(newdata) {
  tp <- subset(newdata, tp==1)
  tn <- subset(newdata, tn==1)
  fp <- subset(newdata, fp==1)
  fn <- subset(newdata, fn==1)
  
  fp_map <- gm11 + geom_point(data=fp, aes(x=lon, y=lat, colour="#000099"))
  fp_map + geom_point(data=tp, aes(x=lon, y=lat, colour="#CC0000")) 
}
map_fpvtp(newdata)

#Create dfs for every hour separately
h1 <- subset(newdata, hournumber_x==1)
h2 <- subset(newdata, hournumber_x==2)
h3 <- subset(newdata, hournumber_x==3)
h4 <- subset(newdata, hournumber_x==4)
h5 <- subset(newdata, hournumber_x==5)
h6 <- subset(newdata, hournumber_x==6)
h7 <- subset(newdata, hournumber_x==7)
h8 <- subset(newdata, hournumber_x==8)
h9 <- subset(newdata, hournumber_x==9)
h10 <- subset(newdata, hournumber_x==10)
h11 <- subset(newdata, hournumber_x==11)
h12 <- subset(newdata, hournumber_x==12)
h13 <- subset(newdata, hournumber_x==13)
h14 <- subset(newdata, hournumber_x==14)
h15 <- subset(newdata, hournumber_x==15)
h16 <- subset(newdata, hournumber_x==16)
h17 <- subset(newdata, hournumber_x==17)
h18 <- subset(newdata, hournumber_x==18)
h19 <- subset(newdata, hournumber_x==19)
h20 <- subset(newdata, hournumber_x==20)
h21 <- subset(newdata, hournumber_x==21)
h22 <- subset(newdata, hournumber_x==22)
h23 <- subset(newdata, hournumber_x==23)

data_hour_list <- list(h1, h2, h3, h4, h5, h6, h7, h8, h9, 
                       h10, h11, h12, h13, h14, h15, h16, 
                       h17, h18, h19, h20, h21, h22, h23)
map_tpvfn_by_hour <- mapply(map_tpvfn, data_hour_list)
