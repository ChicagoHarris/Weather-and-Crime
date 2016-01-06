# Run this file with the following: 
# ./RunPostgres.sh weatherjsons/ChicagoWeather_Update_2015_07_12.csv crimecsvs/ChicagoCrime_Update_2015_07_12.csv

# Requirements: 
# Postgres
# Postgis


# Initialize Section [ Can comment out after initial run. Does not need to be run for every update]:

# Create database credentials
# This should be done manually
# echo "127.0.0.1:5432:postgres:username:password" > .pgpass

# Create weatherandcrime database
#psql postgres < databaseInit.sql

# Update database credentials to use our new database
# Do this manually as well once
# echo "127.0.0.1:5432:weatherandcrime:username:password" > .pgpass

# Enable spatial functions in our database
#postGisScriptDir="/usr/local/Cellar/postgis/2.1.7_1/share/postgis"
#psql -f "$postGisScriptDir/postgis.sql" weatherandcrime
#psql -f "$postGisScriptDir/spatial_ref_sys.sql" weatherandcrime

# Import Shapefile 
# Requires postgis to run shp2pgsql
# and requires Census_Tracts.shp to be in directory.
#shp2pgsql -s 3435 Census_Tracts/Census_Tracts.shp public.censustracts weatherandcrime > censustracts.sql
#psql weatherandcrime < censustracts.sql

# End Initialize Section.


psql weatherandcrime < cleanupdb.sql



# Import Weather and Crime into Postgres

# Weather Import:
# Parameter 1 is the Weather csv generated for this hour/date. 
cp $1 weatherjsons/ChicagoWeather.csv
weathercsvSQL="$(pwd)/weatherjsons/ChicagoWeather.csv"
psql weatherandcrime < weatherimport.sql 
psql weatherandcrime -c "COPY weather FROM '$weathercsvSQL' DELIMITER ',' CSV header;"
# Crime Import: 
# Parameter 2 is the Crime csv generated for this hour/date. 
cp $2 crimecsvs/ChicagoCrime.csv
crimecsvSQL="$(pwd)/crimecsvs/ChicagoCrime.csv"
psql weatherandcrime < CrimeImport.sql
psql weatherandcrime -c "COPY crime FROM '$crimecsvSQL' DELIMITER ',' CSV header;"



# Format Weather and Crime data for Analysis

# Join Weather/Crime/Census together
# This command exports a csv called WeatherandCrime_Data_Iter.csv
psql weatherandcrime < censusweathercrimequery.sql 
