---This creates a csv that joins weather and crimes to census tracts. This is the csv you will use for analysis. 

--run CrimeImport.sql and weatherimport.sql if not already done, to create crime and weather tables, respectively. 

alter table crime add column crimehour timestamp;
--create spatial index on censustracts table
CREATE INDEX ix_censustracts ON censustracts using GIST(geom);
--create geom column on crime table
ALTER TABLE crime ADD COLUMN geom geometry;
--create spatial index on crime table
CREATE INDEX ix_crime ON crime using GIST(geom);
--populate crime spatial index column
UPDATE crime SET geom=ST_SetSRID(ST_POINT(crime.longitude, crime.latitude), 4326);
--create date index on crime table
CREATE INDEX ix_crime_dt ON crime (dt);
--create index on crime for censustract and hours
ALTER TABLE crime ADD COLUMN census_tra varchar(6);
CREATE INDEX ix_crime_tra ON crime (census_tra, id);
CREATE INDEX ix_crime_tra_hr_type ON crime (census_tra,crimehour, iucr, fbicode);
CREATE INDEX ix_crime_id_to_geom ON crime (id, geom);
--put censustract into the correct SRID
alter table censustracts add column geom4326 geometry;

update censustracts
set geom4326 = st_transform(geom, 4326)
;
--index on new SRID column
CREATE INDEX ix_censustracts_g4326 ON censustracts using GIST(geom4326);


-- See how many crimes need census tracts assigned
--select count(*) from crime where census_tra is null and geom is not null;

-- Assign all crimes a census tract
update crime
	set census_tra = A.census_tra
FROM censustracts as A 
, (select id from crime where census_tra is null and geom is not null) B
 WHERE  ST_WITHIN (crime.geom, A.geom4326)
and crime.id = B.id
;


-- Clean up the crime table's time to make subsequent joins easier/faster
update crime set crimehour = date_trunc('hour', dt) ;
create index ix_crime_crimehour on crime (crimehour, primarytype);


--Create weather view. Create one weather reading for each hour (by averaging across all stations with reads). And creating binary variables for weather types (ie rain, snow)
DROP VIEW if exists weather_final;

CREATE OR REPLACE VIEW weather_final
AS
SELECT hourstart
, cast(avg(case when w.wind_speed = '' then null else cast(w.wind_speed AS decimal(18,4)) end) as decimal(18,4)) as wind_speed
, cast(avg(case when w.drybulb_fahrenheit = '' then null else cast(w.drybulb_fahrenheit AS decimal(18,4)) end) as decimal(18,4)) as drybulb_fahrenheit
, cast(avg(case when w.hourly_precip = '' then null else cast(w.hourly_precip AS decimal(18,4)) end) as decimal(18,4)) as hourly_precip
, cast(avg(case when w.relative_humidity = '' then null else cast(w.relative_humidity AS decimal(18,4)) end) as decimal(18,4)) as relative_humidity
, max(case when position('FZ' in w.weather_types) = 0 then 0 else 1 end) as FZ
, max(case when position('RA' in w.weather_types) = 0 then 0 else 1 end) as RA
, max(case when position('TS' in w.weather_types) = 0 then 0 else 1 end) as TS
, max(case when position('BR' in w.weather_types) = 0 then 0 else 1 end) as BR
, max(case when position('SN' in w.weather_types) = 0 then 0 else 1 end) as SN
, max(case when position('HZ' in w.weather_types) = 0 then 0 else 1 end) as HZ
, max(case when position('DZ' in w.weather_types) = 0 then 0 else 1 end) as DZ
, max(case when position('PL' in w.weather_types) = 0 then 0 else 1 end) as PL
, max(case when position('FG' in w.weather_types) = 0 then 0 else 1 end) as FG
, max(case when position('SA' in w.weather_types) = 0 then 0 else 1 end) as SA
, max(case when position('UP' in w.weather_types) = 0 then 0 else 1 end) as UP
, max(case when position('FU' in w.weather_types) = 0 then 0 else 1 end) as FU
, max(case when position('SQ' in w.weather_types) = 0 then 0 else 1 end) as SQ
, max(case when position('GS' in w.weather_types) = 0 then 0 else 1 end) as GS
--, w.*
	FROM  generate_series 
		( '2014-10-01' ::timestamp
		, '2020-01-01' ::timestamp
		, '1 hour' ::interval) as hourstart
	inner join weather w on w.dttime between hourstart -interval '30 minute' and hourstart + interval '29 minute'
group by hourstart
;


--create crime view: create count of crimes by types of interest (homicide, robbery, assault) by censustract and hour
drop view crime_final;
create or replace view crime_final
AS
select 
c.census_tra
, c.crimehour
--create counts
, sum(case when fbicode = '01A' or iucr in ('041A', '041B', '0420', '0430', '0479', '0495') then 1 else 0 end) as shooting_count
, sum(case when fbicode = '04A' then 1 else 0 end) as assault_count
, sum(case when fbicode = '03' then 1 else 0 end) as robbery_count
from crime c 
where fbicode in ('01A', '04A', '03') or iucr in ('041A', '041B', '0420', '0430', '0479', '0495')
group by c.census_tra ,c.crimehour
;


-- This is the query we use to export data 
---Create table with hourly units of analysis ---and export to CSV

-- 
COPY(
SELECT 
ct.census_tra, 
date_part('year', hourstart_series)as year,
date_part('hour', hourstart_series)as hournumber,
cast(hourstart_series as date) as dt, 
coalesce(c.shooting_count,0) as shooting_count,
coalesce(c.robbery_count,0) as robbery_count,
coalesce(c.assault_count,0) as assault_count,

w.*,
w.drybulb_fahrenheit - w_prev_d1.drybulb_fahrenheit as dod1_drybulb_fahrenheit,
w.drybulb_fahrenheit - w_prev_d2.drybulb_fahrenheit as dod2_drybulb_fahrenheit,
w.drybulb_fahrenheit - w_prev_d3.drybulb_fahrenheit as dod3_drybulb_fahrenheit,
w.drybulb_fahrenheit - w_prev_w1.drybulb_fahrenheit as wow1_drybulb_fahrenheit,
w.drybulb_fahrenheit - w_prev_w2.drybulb_fahrenheit as wow2_drybulb_fahrenheit,
hour_prec_history.precip_hour_cnt_in_last_1_day,
hour_prec_history.precip_hour_cnt_in_last_3_day,
hour_prec_history.precip_hour_cnt_in_last_1_week,
hour_prec_history.hour_count_since_precip,
date_part('month', hourstart_series)as month_of_year,
extract(DOW FROM hourstart_series)as day_of_week
/* Note that Monday is 1 */
FROM 
censustracts ct
INNER JOIN generate_series 
	( '2014-10-01' ::timestamp
	/*, '2008-01-01' ::timestamp */ 
	, '2020-01-01' ::timestamp
	, '1 hour' ::interval) hourstart_series ON 1=1

LEFT JOIN crime_final c ON hourstart_series = c.crimehour AND ct.census_tra = c.census_tra
INNER JOIN weather_final w ON hourstart_series = w.hourstart
LEFT JOIN weather_final w_prev_d1 ON hourstart_series - INTERVAL '1 day' = w_prev_d1.hourstart
LEFT JOIN weather_final w_prev_d2 ON hourstart_series - INTERVAL '2 day' = w_prev_d2.hourstart
LEFT JOIN weather_final w_prev_d3 ON hourstart_series - INTERVAL '3 day' = w_prev_d3.hourstart
LEFT JOIN weather_final w_prev_w1 ON hourstart_series - INTERVAL '1 week' = w_prev_w1.hourstart
LEFT JOIN weather_final w_prev_w2 ON hourstart_series - INTERVAL '2 week' = w_prev_w2.hourstart

left join 
(
	select hourstart_series2
	, sum (
		case when w.hourstart between hourstart_series2 - INTERVAL '1 day' and hourstart_series2 then 1 else 0 end
		) as precip_hour_cnt_in_last_1_day
	, sum (
		case when w.hourstart between hourstart_series2 - INTERVAL '3 day' and hourstart_series2 then 1 else 0 end
		) as precip_hour_cnt_in_last_3_day
	, sum (
		case when w.hourstart between hourstart_series2 - INTERVAL '1 week' and hourstart_series2 then 1 else 0 end
		) as precip_hour_cnt_in_last_1_week
	, EXTRACT(EPOCH FROM hourstart_series2 - max(w.hourstart))/3600 as hour_count_since_precip
	from generate_series ( '2008-01-01' ::timestamp, '2020-01-01' ::timestamp, '1 hour' ::interval) hourstart_series2
	inner join weather_final w on w.hourstart between hourstart_series2 - INTERVAL '8 week' and hourstart_series2
	where w.hourly_precip > 0
	group by hourstart_series2
) as hour_prec_history
	on hourstart_series = hour_prec_history.hourstart_series2

order by hourstart_series, ct.census_tra
)

TO '/Users/maggiek/Public/Drop Box/WeatherandCrime_Data_Testing.csv' WITH csv HEADER
-- TO '/Users/maggieking/Documents/WeatherandCrime/Weather-and-Crime/Updater/WeatherandCrime_Data_Iter.csv' WITH csv HEADER
;