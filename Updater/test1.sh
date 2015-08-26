#!/bin/bash
for i in `seq 1 100`

do
echo $i
Rscript updateNN_NoWeather.R shooting_count /mnt/research_disk_1/newhome/weather_crime/Weather-and-Crime/Master_Pipeline/shooting/binned_csv/ /mnt/research_disk_1/newhome/weather_crime/Weather-and-Crime/Master_Pipeline/no_weather_shooting/ $i 5 2015-07-06

done 
