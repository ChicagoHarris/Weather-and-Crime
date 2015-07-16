# Notes to Jiajun [Repeated from updatingScript.sh]: 
# 1. Parameters passed in line 7 need to update automatically with latest csv available. 
# 2. Weather data should go back far enough to create lagged variables for each day in the data. 


# Run this file with the following: 
# ./RunPostgres.sh weatherjsons/ChicagoWeather_Update_2015_07_12.csv crimecsvs/ChicagoCrime_Update_2015_07_12.csv

# Requirements: 
# Postgres
# Postgis


# Initialize Section [ Can comment out after initial run. Does not need to be run for every update]:

# Create database credentials
# This should be done manually _once_ forever.  The reason being we don't want the password in version control
# echo "127.0.0.1:5432:postgres:username:password" > .pgpass

# Create weatherandcrime database
psql postgres < databaseInit.sql

# Update database credentials to use our new database
# Do this manually as well once
# echo "127.0.0.1:5432:weatherandcrime:username:password" > .pgpass

# Enable spatial functions in our database
postGisScriptDir="/usr/local/Cellar/postgis/2.1.7_1/share/postgis"
psql -f "$postGisScriptDir/postgis.sql" weatherandcrime
psql -f "$postGisScriptDir/spatial_ref_sys.sql" weatherandcrime

# Import Shapefile 
# Requires postgis to run shp2pgsql
# and requires Census_Tracts.shp to be in directory.
shp2pgsql -s 3435 Census_Tracts/Census_Tracts.shp public.censustracts weatherandcrime > censustracts.sql
psql weatherandcrime < censustracts.sql

# End Initialize Section.






# Import Weather and Crime into Postgres

# Weather Import:
# Parameter 1 is the Weather csv generated for this hour/date. 
cp $1 weatherjsons/ChicagoWeather.csv
psql weatherandcrime < weatherimport.sql

# Crime Import: 
# Parameter 2 is the Crime csv generated for this hour/date. 
cp $2 crimecsvs/ChicagoCrime.csv
psql weatherandcrime < CrimeImport.sql


# Format Weather and Crime data for Analysis

# Join Weather/Crime/Census together
# This command exports a csv called WeatherandCrime_Data_Iter.csv
psql weatherandcrime < censusweathercrimequery.sql 
