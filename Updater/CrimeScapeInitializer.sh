# CrimeScape Initializer


# For Updater Pipeline
# Run from project's Updater directory: Weather-and-Crime/Updater/


## For Getting the data
brew install jq
brew install wget
brew install go

# set GOPATH
mkdir $HOME/work
export GOPATH=$HOME/work
export PATH=$PATH:$GOPATH/bin

go get github.com/jehiah/json2csv

## For Formatting the data

#postgres
brew install postgresql
#postgis
brew install postgis


# Start postgres on OS X
launchctl load /usr/local/Cellar/postgresql/9.4.4/homebrew.mxcl.postgresql.plist

# If you get an error that role "postgres" does not exist, run: 
psql postgres
# In postgres run:
create role postgres;   #Sets "postgres" as your username
\password postgres
# Enter desired password.  #Sets your password for username "postgres". 
#Username and password set here are used in lines 42 and 49 below. 
\q # to exit postgres

# Create database credentials with following syntax: 
#echo "127.0.0.1:5432:postgres:username:password" > .pgpass
echo "127.0.0.1:5432:postgres:postgres:postgres" > .pgpass

# Create database
psql postgres < databaseInit.sql

# Update database credentials to use our new database with following syntax:
#echo "127.0.0.1:5432:weatherandcrime:username:password" > .pgpass
echo "127.0.0.1:5432:weatherandcrime:postgres:postgres" > .pgpass

# Enable spatial functions in our database
postGisScriptDir="/usr/local/Cellar/postgis/2.1.7_1/share/postgis"
psql -f "$postGisScriptDir/postgis.sql" weatherandcrime
psql -f "$postGisScriptDir/spatial_ref_sys.sql" weatherandcrime

# Import Shapefile 
# Requires postgis to run shp2pgsql
# and requires Census_Tracts.shp to be in directory.
shp2pgsql -s 3435 Census_Tracts/Census_Tracts.shp public.censustracts weatherandcrime > censustracts.sql
psql weatherandcrime < censustracts.sql

# R updater section
R
install.packages("nnet")
install.packages("neuralnet")
# End Initialize Section.

# To pull most recent models output from server: 
scp maggiek@128.135.232.75:/mnt/research_disk_1/newhome/weather_crime/Weather-and-Crime/Master_Pipeline/output/prediction_daily*.csv ./
