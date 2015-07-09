#!/bin/sh
#This script conducts the whole process of pulling forecast data to outputting the csv to the dropbox folder.
bash GetUpdateWeatherData
bash GetUpdateMetarData
#Pull forecast data from noaa
python forecastScraper.py

#Merge and reformat plenario metar and qcd data and noaa forecast data.
python reformat_plenario_weather.py
mv lagged_forecasts.csv LagBin
cd LagBin

#Bin lagged_forecats.csv; output is binned_forecasts.csv
bash bag_and_bin_prediction_pipeline.sh
mv binned_forecasts.csv ..
cd ..
#Create robbery predictions
Rscript testNN_robbery_edited.R "robbery" robbery/binned_csv/ robbery/ output/ 100 binned_forecasts.csv
Rscript testNN_robbery_edited.R "assault" assault/binned_csv/ assault/ output/ 100 binned_forecasts.csv
Rscript testNN_robbery_edited.R "shooting" shooting/binned_csv/ shooting/ output/ 100 binned_forecasts.csv
cd output
python add_id.py
mv Crime\ Prediction\ CSV\ MOCK\ -\ revised.csv ~/Dropbox/Public/Mockup\ CSV\ Folder/
