DROP TABLE IF EXISTS crime;

CREATE TABLE crime 
(ID int, 
CaseNumber varchar(100), 
Dt timestamp, 
Block varchar(100), 
iucr varchar(100), 
PrimaryType varchar(100), 
Description varchar(1000),
LocationDescription varchar(1000),
Arrest varchar(25),
Domestic varchar(25),
Beat varchar(25),
District varchar(25),
Ward varchar(25),
CommunityArea varchar(25),
fbicode varchar(25),
XCoordinate double precision,
YCoordinate double precision,
Year int,
UpdatedOn varchar(100),
Latitude double precision,
Longitude double precision,
Location varchar(100) ); 

-- COPY crime FROM '/Users/maggiek/Desktop/ChicagoCrime.csv' DELIMITER ',' CSV header;

-- Note: change location for ANL when access is restored. 
COPY crime FROM '/Users/jeff/wsPersonal/WeatherAndCrimeLatest/Updater/crimecsvs/ChicagoCrime.csv' DELIMITER ',' CSV header;


