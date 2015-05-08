args <- commandArgs(trailingOnly = TRUE)
print("====Processing Input Parameters====")
if(length(args)!=4){
    print("[Error] Invalid Input Parameters")
    quit()
}
print("========crime type=============")
print(args[1])
crimeType = args[1]
print("========directory to raw data=========")
print(args[2])
rawDataDir = args[2]
print("=====directory to output training data=====")
print(args[3])
trainingDataDir = args[3]
print("=====directory to output testing data=======")
print(args[4])
testingDataDir = args[4]

# load the raw data
print("loading csv ...")
crimeData = read.csv(rawDataDir)

# create time as Type time
crimeData$time = as.POSIXct(crimeData$hourstart, format="%Y-%m-%d %H:%M:%S")
crimeData$month = strftime(crimeData$time, "%m")
crimeData$day = strftime(crimeData$time, "%d")

print("finish loading ...")

# specify all the covariates we will use to model
covariates = c("census_tra", "month","day","hournumber", crimeType, "wind_speed", "drybulb_fahrenheit", "hourly_precip", "relative_humidity", "dod_drybulb_fahrenheit")

# specify the variables that we will binning
binningCovariates = c("wind_speed","drybulb_fahrenheit","hourly_precip","relative_humidity","dod_drybulb_fahrenheit")
# create empty dataframe template to process data


binarizeData(crimeData, covariates, binningCovariates, 30, crimeType)

templateData = data.frame()
