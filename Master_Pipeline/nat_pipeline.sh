#!/bin/sh

# Jiajun temporary change
#DATAPATH=[PATH TO DATA AND MODEL]
UpdaterPATH="../Updater"

LATESTMODEL_Date=`cat $UpdaterPATH/modelUpdateDate.txt`
#
LATESTMODEL_YEAR=`cat $UpdaterPATH/modelUpdateDate.txt|cut -f1 -d '-'`
LATESTMODEL_MONTH=`cat $UpdaterPATH/modelUpdateDate.txt|cut -f2 -d '-'`
LATESTMODEL_DAY=`cat $UpdaterPATH/modelUpdateDate.txt|cut -f3 -d '-'`


bash GetUpdateWeatherData
bash GetUpdateMetarData
#timeout 30s python forecastScraper.py
sleep 15
python forecastScraper.py
#cp forecasts.csv Weather_Forecasts.csv
#mv -f Weather_Forecasts.csv ~/Dropbox/Public/Mockup\ CSV\ Folder/
python reformat_plenario_weather.py
mv -f Weather_Forecasts.csv ~/Dropbox/Public/Mockup\ CSV\ Folder/
mv lagged_forecasts.csv LagBin
cd LagBin
bash bag_and_bin_prediction_pipeline.sh
#cp forecasts.csv Weather_Forecasts.csv
#mv Weather_Forecasts.csv ~/Dropbox/Public/Mockup\ CSV\ Folder/
mv binned_forecasts.csv ..
cd ..

#The location and the format of the NN model would be: $DATAPATH/._NNmodel_$crimeType_$indexOfBaggedSamples_Update_$LATESTMODEL_Date.rds


Rscript testNN_robbery_edited.R "robbery_count" robbery/binned_csv/ robbery/ output/ 100 binned_forecasts.csv $LATESTMODEL_Date &
Rscript testNN_robbery_edited.R "assault_count" assault/binned_csv/ assault/ output/ 100 binned_forecasts.csv $LATESTMODEL_Date &
Rscript testNN_robbery_edited.R "shooting_count" shooting/binned_csv/ shooting/ output/ 100 binned_forecasts.csv $LATESTMODEL_Date &
wait
cd output
python add_id.py
mv Crime\ Prediction\ CSV\ MOCK\ -\ revised.csv ~/Dropbox/Public/Mockup\ CSV\ Folder/
