#!/bin/sh
bash weatherjsons/GetUpdateWeatherData
mv weatherjsons/ChicagoWeather_Update_.csv
python forecastScraper.py
cat ChicagoWeather_Update_.csv forecasts.csv > final_weather.csv
#average weather stations, add census tracts, and lagged effects
#binning

#DATAPATH=/mnt/research_disk_1/newhome/weather_crime/data/
#Robbery models output weather variables as well as predictions
Rscript testNN_robbery_edited.R "robbery_count" binned_csv/ robbery_models/ output/ 100 WeatherandCrime_Data.robbery.1.binned.csv

Rscript testNN_robbery_edited.R "assault_count" binned_csv/ robbery_models/ output/ 100 WeatherandCrime_Data.assault.1.binned.csv

Rscript testNN_robbery_edited.R "shooting_count" binned_csv/ robbery_models/ output/ 100 WeatherandCrime_Data.shooting.1.binned.csv
cd /output
paste -d , prediction_robbery.csv prediction_assault.csv prediction_shooting.csv > final_output.csv