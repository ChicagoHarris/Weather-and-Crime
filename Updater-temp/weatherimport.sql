
DROP TABLE IF EXISTS weather;

CREATE TABLE weather
(
wind_speed varchar(100),
sealevel_pressure varchar(100),
old_station_type varchar(100),
station_type varchar(100),
sky_condition varchar(100),
wind_direction varchar(100),
sky_condition_top varchar(100),
visibility varchar(100),
dttime timestamp without time zone,
wind_direction_cardinal varchar(100),
relative_humidity varchar(100),
hourly_precip varchar(100),
drybulb_fahrenheit varchar(100),
report_type varchar(100),
dewpoint_fahrenheit varchar(100),
station_pressure varchar(100),
weather_types varchar(500),
wetbulb_fahrenheit varchar(100),
wban_code integer
) ;

CREATE INDEX ix_station ON weather (wban_code, dttime);

CREATE INDEX ix_time ON weather (dttime, wind_speed, drybulb_fahrenheit, hourly_precip, relative_humidity, weather_types);

--COPY weather FROM '/Users/maggiek/Desktop/sc/Weatherandcrime/data/ChicagoWeather.csv' DELIMITER ',' CSV header;

-- Note: change location for ANL when access is restored. 
--COPY weather FROM '/Users/jeff/wsPersonal/WeatherAndCrimeLatest/Updater/weatherjsons/ChicagoWeather.csv' DELIMITER ',' CSV header;
--COPY weather FROM "\:weathercsv" DELIMITER ',' CSV header;

