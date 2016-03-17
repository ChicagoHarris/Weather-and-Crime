Weather-and-Crime
==========
This project uses enhanced analytical methods to identify patterns in the relationship between weather and crime that predict violent crime. 

Crime data is from the City of Chicago. Weather data is from NOAA, via the Plenar.io API which offers cleaned Chicago weather data for hourly reports from the city. US Census block and tract shapefiles are used to define the geospatial unit of analysis for the study. 

This project is funded by a grant from the Arnold Foundation and is housed at the University of Chicago.

Dependencies & Set-up
============
Run CrimeScapeInitializer.sh to install these

- Postgres (installed in manual_initialization.txt)
- Postgis
- jq
- go
- jsontocsv from github.com/jehiah/json2csv
- R

DATABASE & R INITIALIZATION:

The database will need to be initialized once using postgres. Instructions on how to this are found in manual_initialization.txt. This file will need to be run line by line in the terminal as output will need to be adjusted based on the output from the installing scripts. Usernames and passwords will also need to be set manually in postgres.

Master Pipeline:
================
Main file: Master_pipeline/nat_pipeline.sh 
	Gets new weather data for the last 30 days and runs it through a saved model. This model assumes saved crime data and 
	models as detailed in the documentation on the file.
	
- testNN_*.R files run current weather and crime data through models that have already been trained and saved
- User will need to adjust file locations in pipeline to output data to their desired locations.

	

Training Pipeline:
================
- Initialized through manually loaded data following directions in AccessData/GetDataScripts, log locations where data is stored. 
- Create Postgres database and import data from local storage and join with files in ImportDataScripts
- Bags observations of crimes into 100 files and bins weather data

Updater Pipeline:
================
Main function: Updater/updatingScript.sh

This pipeline runs new models taking the previous run of models as a baseline and updating them to include more up-to-date data, in this case, the last 30 days of data are included. The old models are stored in archived folder with their date and the new ones are copied to the active server.

Model Updating:
The initial models are trained using a neural network model that iterates up to 200 times through interconnected nodes with varying weights attempting to provide an accurate output classification based on the training data. On each iteration, the internal weights of the model (how each variable interacts with each other, many times over) is adjusted to minimize the loss function (a calculation of how   well classified points are) on the initial run until the loss function is no longer able to decrease. This is know as stochastic gradient descent. 
This process makes updating the model easier as the difficult work of the initial work of tuning the weights is done. The new data is introduced into the model and the model then runs again to continue to minimize the loss function by looking at random samples of the training data. The convergance happens much faster with the pre-set weights and new weights, incorporating more recent data, help to keep the predictions up-to-date while reducing training time.

 - Updates the crime and weather data from the same date in the prior month to the current date. 
 	GetUpdateCrimeData.sh - Updates crime data from Plenario API for all of the City of Chicago
	GetUpdateWeatherData.sh - Updates weather data from Plenario API from 4 stations in the Chicago area

 - Join weather, crime and shapefiles in Postgres to output data for use in the final model. Assumes that the database has been initialized properly.

 	RunPostgres.sh

 - Bags observations of crimes into 100 files with randomly chosen non-observations such that each file is 50% tracts/hour combinations that had crimes and 50% combinations that did not. Also bins weather observations into predetermined, accepted bins.

 	bag_and_bin.sh

 - Update model with new data and saves model to a datapath/{crimename} directory
  - parallelUpdatingScript.sh
  
Helpers
=========
- Contains awk scripts with information about how weather data is binned

Additional Background
=========
Read more about the data and model <a href="http://chicagoharris.github.io/Weather-and-Crime">here</a>.











