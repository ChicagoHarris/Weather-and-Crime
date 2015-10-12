# Note: Before executing these scripts, check to ensure that paths are up to date in pointing from one file to the next.

# Follow directions in GetDataScripts: 
# GetCrimeData
# GetWeatherData
# GetCensusShapeFile

# Then import to postgres by following directions in scripts in ImportDataScripts: 
# ImportToPostgresql_CensusShapefile
## Related file: censustracts.sql
# CrimeImport.sql
# weatherimport.sql
# Output of Import scripts: Three (3) separate tables, one for each of Weather, Crime, and Census Tracts

#Format data in postgres with: 
# censusweathercrimequery.sql  
## Interim Output: a csv of panel data joining weather and crime data into censustracts and hours. 
## Move this output csv to the FormatDataScripts directory to run bag_and_bin.sh
# bag_and_bin.sh {Interim Output csv, described above} N
# Output of Format scripts: N csvs of bagged and binned data, each a mini version, with downsampled 0 cases, of InterimOutput csv.

# Transfer to ANL
#starting in /Weather-and-Crime/Training_Pipeline/AccessData

# Compress data into one file to send 
tar -cvf Robbery.tar robbery/*binned*
tar -cvf Assault.tar assault/*binned*
tar -cvf Shooting.tar shooting/*binned*

# Make the transfer to ANL (takes a while)
scp Shooting.tar {ANL user address}:~/data

# when in ANL (perform next steps in ANL data dir)
tar -xvf Robbery.tar 
gunzip robbery/*.gz

tar -xvf Assault.tar 
gunzip assault/*.gz

tar -xvf Shooting.tar 
gunzip shooting/*.gz