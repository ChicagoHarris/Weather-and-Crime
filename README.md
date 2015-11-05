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




