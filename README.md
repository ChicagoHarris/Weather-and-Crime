Weather-and-Crime
==========
This project uses enhanced analytical methods to estimate the link between weather and crime. 

Crime data is from the City of Chicago. Weather data is from NOAA, via the Plenar.io API which offers cleaned Chicago weather data for hourly reports from the city. US Census block and tract shapefiles are used to define the geospatial unit of analysis for the study. 

This project is funded by a grant from the Arnold Foundation and is housed at the University of Chicago.

Use the Get* scripts to pull the data, and then the Import scripts to centralize and format for analysis in R.



##How to Run

### Before you start

* Set the PATH in the bash file `./script/execute.sh`. Make sure you already create directory for data and models.

### Run the Code

* Run the command `./script/execute.sh`. It will go through three stages:  
    1) Preprocess the historical data and the forecast data;  
    2) Training the model with bagging in parallel;  
    3) Testing the model, and produce the prediction csv file;  
