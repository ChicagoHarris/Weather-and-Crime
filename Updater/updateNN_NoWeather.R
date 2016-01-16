    #How to Run:
    #Rscript updateNN.R [crimeType] [directory to updated data] [directory to base model file] [Index of bagged Samples: {1,2,3,...number of bagged samples}] [number of hidden node] [number of iterations] [datetime of updating]
    #Example: Rscript updateNN.R "robbery_count" $DATAPATH $DATAPATH 1 10 "2015-05-20"

    library(neuralnet)
    library(nnet)

    args <- commandArgs(trailingOnly = TRUE)

    print("======processing input parameters==========")

    if(length(args) != 7){
        print("[Error] Invalid Input Parameters")
        quit()
    }

    ##Specifying the input parameters
    print("======crime type========")
    print(args[1])
    crimeType = args[1]
    
    print("======yvar========")
    print(args[2])
    yvar = args[2]
    
    print("=====directory to updated data========")
    print(args[3])
    updateDataDir = args[3]
    
    print("======directory to input model========")
    print(args[4])
    modelDir = paste('no_weather_',args[4])
    
    print("======Index of Bagged Samples=========") 
    print(args[5])
    indexOfBaggedSamples = as.integer(args[5])
    
    print("=====Number of Updating Iterations============")
    print(args[6])
    nIter = as.integer(args[6])
    
    print("====Datetime of updating=============")
    print(args[7])
    dateTime = args[7]
    


    #load updated training data. The updated training data is the combination of historical bagged data and the updated bagged data
    print("loading historic training data...")
    #trainingData = readRDS(file = paste(updateDataDir, "/.bagTrainingData_", crimeType, "_", indexOfBaggedSamples, ".rds", sep = ""))
    trainingData = read.csv(paste(updateDataDir, "/WeatherandCrime_Data_Iter.", crimeType, ".", indexOfBaggedSamples, ".binned.csv", sep = ""))
    trainingData = data.frame(trainingData)


    print("Done")


    print("loading updated data....")
    #updatedData = readRDS(file = paste(updateDataDir,"/.bagTrainingData_",crimeType,"_Update_",dateTime, "_Index_", indexOfBaggedSamples, ".rds", sep=""))
    #updatedData = read.csv(paste(updateDataDir,"/WeatherandCrime_Data.",crimeType,"Update.",dateTime, ".", indexOfBaggedSamples, ".binned.csv", sep=""))
    #updatedData = data.frame(updatedData)
    #print("Done")
    #print(ncol(trainingData))
    #print(ncol(updatedData))

    #Append updated data with the historic training data. And save to historic datas
    #trainingData = rbind(trainingData,updatedData)
    print(ncol(trainingData))
    #saveRDS(trainingData,file = paste(updateDataDir, "/.bagTrainingData_", crimeType, "_", indexOfBaggedSamples, ".rds", sep = ""))
    #write.csv(trainingData, file = paste(updateDataDir, "/WeatherandCrime_Data.", crimeType, ".", indexOfBaggedSamples, ".binned.csv", sep = ""), row.names=FALSE)

    print("Done")

    ##Prepare the actuall data need to be trained.
    names = names(trainingData)
    predictors = trainingData[!names %in% c("shooting_count", "census_tra", "year", "hournumber", "dt", "robbery_count", "assault_count", "hourstart", "wind_speed", "drybulb_fahrenheit", "hourly_precip", "relative_humidity", "dod1_drybulb_fahrenheit", "dod2_drybulb_fahrenheit", "dod3_drybulb_fahrenheit", "wow1_drybulb_fahrenheit", "wow2_drybulb_fahrenheit", "precip_hour_cnt_in_last_1_day", "precip_hour_cnt_in_last_3_day", "precip_hour_cnt_in_last_1_week", "hour_count_since_precip", "month_of_year", "day_of_week","temp_<_neg20","temp_neg20_to_neg11","temp_neg10_to_neg1","temp_0_to_9","temp_10_to_19","temp_20_to_29","temp_30_to_39","temp_40_to_49","temp_50_to_59","temp_60_to_69","temp_70_to_79","temp_80_to_89","temp_90_to_99","temp_100_to_109","temp_110_to_119","temp_>=_120","wind_<_5mph","wind_5_to_10mph","wind_11_to_15mph","wind_16_to_20mph","wind_21_to_25mph","wind_26_to_30mph","wind_31_to_35mph","wind_36_to_40mph","wind_41_to_45mph","wind_46_to_50mph","wind_>=_50mph","rain_=0","rain_0_to_.01","rain_.01_to_.02","rain_.02_to_.03","rain_.03_to_.04","rain_.04_to_.05","rain_.05_to_0.1","rain_0.1_to_0.2","rain_0.2_to_0.3","rain_0.3_to_0.4","rain_0.4_to_0.5","rain_0.5_to_1","rain_>1","humidity_<10","humidity_10_to_20","humidity_20_to_30","humidity_30_to_40","humidity_40_to_50","humidity_50_to_60","humidity_60_to_70","humidity_70_to_80","humidity_80_to_90","humidity_90_to_100","wow_1_change_=0","wow_1_change_1_to_5","wow_1_change_5_to_10","wow_1_change_10_to_20","wow_1_change_20_to_30","wow_1_change_30_to_40","wow_1_change_40_to_50","wow_1_change_>50","wow_1_change_neg1_to_neg5","wow_1_change_neg5_to_neg10","wow_1_change_neg10_to_neg20","wow_1_change_neg20_to_neg30","wow_1_change_neg30_to_neg40","wow_1_change_neg40_to_neg50","wow_1_change_>neg50","wow_2_change_=0","wow_2_change_1_to_5","wow_2_change_5_to_10","wow_2_change_10_to_20","wow_2_change_20_to_30","wow_2_change_30_to_40","wow_2_change_40_to_50","wow_2_change_>50","wow_2_change_neg1_to_neg5","wow_2_change_neg5_to_neg10","wow_2_change_neg10_to_neg20","wow_2_change_neg20_to_neg30","wow_2_change_neg30_to_neg40","wow_2_change_neg40_to_neg50","wow_2_change_>neg50","dod_1_change_=0","dod_1_change_1_to_5","dod_1_change_5_to_10","dod_1_change_10_to_20","dod_1_change_20_to_30","dod_1_change_30_to_40","dod_1_change_40_to_50","dod_1_change_>50","dod_1_change_neg1_to_neg5","dod_1_change_neg5_to_neg10","dod_1_change_neg10_to_neg20","dod_1_change_neg20_to_neg30","dod_1_change_neg30_to_neg40","dod_1_change_neg40_to_neg50","dod_1_change_>neg50","dod_2_change_=0","dod_2_change_1_to_5","dod_2_change_5_to_10","dod_2_change_10_to_20","dod_2_change_20_to_30","dod_2_change_30_to_40","dod_2_change_40_to_50","dod_2_change_>50","dod_2_change_neg1_to_neg5","dod_2_change_neg5_to_neg10","dod_2_change_neg10_to_neg20","dod_2_change_neg20_to_neg30","dod_2_change_neg30_to_neg40","dod_2_change_neg40_to_neg50","dod_2_change_>neg50","dod_3_change_=0","dod_3_change_1_to_5","dod_3_change_5_to_10","dod_3_change_10_to_20","dod_3_change_20_to_30","dod_3_change_30_to_40","dod_3_change_40_to_50","dod_3_change_>50","dod_3_change_neg1_to_neg5","dod_3_change_neg5_to_neg10","dod_3_change_neg10_to_neg20","dod_3_change_neg20_to_neg30","dod_3_change_neg30_to_neg40","dod_3_change_neg40_to_neg50","dod_3_change_>neg50","rain_1d_count_=0","rain_1d_count_1_to_5","rain_1d_count_5_to_10","rain_1d_count_10_to_20","rain_1d_count_20_to_24","rain_2day_count_=0","rain_2day_count_1_to_5","rain_2day_count_5_to_10","rain_2day_count_10_to_20","rain_2day_count_20_to_24","rain_2day_count_24_to_30","rain_2day_count_30_to_36","rain_2day_count_37_to_47","rain_2day_count_48_to_57","rain_2day_count_58_to_65","rain_2day_count_66_to_72","rain_1week_count_=0","rain_1week_count_1_to_5","rain_1week_count_5_to_10","rain_1week_count_10_to_20","rain_1week_count_20_to_24","rain_1week_count_24_to_30","rain_1week_count_30_to_36","rain_1week_count_37_to_47","rain_1week_count_48_to_57","rain_1week_count_58_to_65","rain_1week_count_66_to_72","rain_1week_count_73_to_96","rain_1week_count_97_to_120","rain_1week_count_121_to_144","rain_1week_count_145_to_168","since_rain_count_=0","since_rain_count_1_to_5","since_rain_count_5_to_10","since_rain_count_10_to_20","since_rain_count_20_to_24","since_rain_count_24_to_30","since_rain_count_30_to_36","since_rain_count_37_to_47","since_rain_count_48_to_57","since_rain_count_58_to_65","since_rain_count_66_to_72","since_rain_count_73_to_96","since_rain_count_97_to_120","since_rain_count_121_to_144","since_rain_count_145_to_168","since_rain_count_>168")]

    crimeResponse = trainingData[yvar]
    trainingData = cbind(crimeResponse, predictors)

    #load trained NN. Filename sample: ._NNmodel_1.rds
    trainedNN = readRDS(file = paste(modelDir,'/',crimeType, "/._NNmodel_NOWEATHER_", indexOfBaggedSamples, ".rds", sep = "")) 

    #Get the number of hidden nodes of the trained NN
    nHidden = trainedNN$n[2]

    #Get the model formula to prepare to update the new NN.
    #yvarColumnName = c("shooting_count", "robbery_count", "assault_count")
    #names = names(trainingData)
    #f <- as.formula(paste(paste(crimeType," ~"), paste(names[!names %in% crimeTypeColumnName], collapse = " + ")))
    f <- as.formula(paste(yvar, paste('~', paste(colnames(trainingData), collapse = '+'))))   



    #Update NN model; Key trick here it to specify "Wts = trainedNN$wts". This allow us to extract the weight parameter trained in the previous NN and start updating weights from there.
    # Thus, we only need to update the model for a small number of interations instead of running another 200 iterations.

    ir.nn = nnet(f, data = trainingData, size = nHidden, rang = 0.1, MaxNWts = 30000, decay = 5e-4, maxit = nIter, Wts = trainedNN$wts)


    #Save updated model in model directory. Filename sample: ._NNmodel_1_Update_2015-05-21.rds
    print("Saving model.....")
    saveRDS(ir.nn, file = paste(modelDir,'/',crimeType, "/._NNmodel_NoWeather_", crimeType, "_", indexOfBaggedSamples, "_Update_", dateTime, ".rds", sep = ""))

    print(paste("Model_", indexOfBaggedSamples, "Finished Updating on ", dateTime))



    
