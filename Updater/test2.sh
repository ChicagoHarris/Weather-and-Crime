#!/bin/bash
for i in `seq 1 100`

do
echo $i
Rscript updateNN_NoWeather.R robbery_count /mnt/research_disk_1/newhome/weather_crime/Weather-and-Crime/Master_Pipeline/robbery/binned_csv/ /mnt/research_disk_1/newhome/weather_crime/Weather-and-Crime/Master_Pipeline/no_weather_robbery/ $i 5 2015-07-06

done 
