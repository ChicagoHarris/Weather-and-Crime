Weather-and-Crime
==========
This project uses enhanced analytical methods to identify patterns in the relationship between weather and crime that predict violent crime. 

Crime data is from the City of Chicago. Weather data is from NOAA, via the Plenar.io API which offers cleaned Chicago weather data for hourly reports from the city. US Census block and tract shapefiles are used to define the geospatial unit of analysis for the study. 

This project is funded by a grant from the Arnold Foundation and is housed at the University of Chicago.

DEPENDENCIES:
Run CrimeScapeInitializer.sh to install these

- Postgres (installed in manual_initialization.txt)
- Postgis
- jg
- go
- jsontocsv from github.com/jehiah/json2csv
- R

DATABASE & R INITIALIZATION:

The database will need to be initialized once using postgres. Instructions on how to this are found in manual_initialization.txt. This file will need to be run line by line in the terminal as output will need to be adjusted based on the output from the installing scripts. Usernames and passwords will also need to be set manually in postgres.

UPDATER PIPELINE:

Main function is updatingScript.sh in Updater folder. 

 - Updates the crime and weather data from the same date in the prior month to the current date. 
 	GetUpdateCrimeData.sh - Updates crime data from Plenario API for all of the City of Chicago
	GetUpdateWeatherData.sh - Updates weather data from Plenario API from 4 stations in the Chicago area

 - Join weather, crime and shapefiles in Postgres to output data for use in the final model. Assumes that the database has been initialized properly.

 	RunPostgres.sh

 - Bags observations of crimes into 100 files with randomly chosen non-observations such that each file is 50% tracts/hour combinations that had crimes and 50% combinations that did not. Also bins weather observations into predetermined, accepted bins.

 	bag_and_bin.sh

 - Update model with new data and saves model to a datapath/{crimename} directory
  - parallelUpdatingScript.sh











