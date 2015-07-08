##Pipeline

This pipeline begins by pulling weather data from two sources:
	1) Historical Metar and QCD data from Plenario
	2) Forecast data from NOAA

###How to Run
The pipeline takes approximately 30 minutes and can be ran using by the command
```
bash nat_pipeline.sh
```

###Contents
The necessary scripts are all included here but the RDS model files are not due to size and number.
	*nat_pipeline.sh
	*GetUpdateWeatherData
	*GetUpdateMetarData
	*forecastScraper.py
	*reformat_plenario_weather.py
	*bag_and_bin_prediction_pipeline.sh
	*testNN_robbery_edited.R
	*add_id.py