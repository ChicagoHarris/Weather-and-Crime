#This python file pulls weather forecast data for Chicago from NOAA. Currently has temperature, humidity, wind speed, rain, snow, ice, hail,
#and probability of a thunderstorm.

import pandas as pd
import requests
import bs4
from datetime import datetime
import time
import numpy as np


#Pull the different datetime intervals
def pullDatetimes(xmlsoup):
	datetime = xmlsoup.data.findAll('time-layout')
	intervalOneHour = xmlsoup.data.parameters.temperature['time-layout']
	intervalSixHour = xmlsoup.data.parameters.precipitation['time-layout']
	intervalDaily = xmlsoup.data.parameters.findAll('severe-component')
	for kind in intervalDaily:
		if kind['type'] == 'hail':
			intervalDaily1 = kind['time-layout']
		else:
			intervalDaily7 = kind['time-layout']

	for stamp in datetime:
		interval = stamp.findAll('layout-key')[0].text
		if interval == intervalOneHour:
			datetime1 = [date.text for date in stamp.findAll('start-valid-time')]
		elif interval == intervalSixHour:
			datetime2 = [date.text for date in stamp.findAll('start-valid-time')]
		elif interval == intervalDaily1:
			datetime3 = [date.text for date in stamp.findAll('start-valid-time')]
		elif interval == intervalDaily7:
			datetime4 = [date.text for date in stamp.findAll('start-valid-time')]
	datetime = {'datetime1':datetime1,'datetime2':datetime2,'datetime3':datetime3,'datetime4':datetime4}
	return datetime


#Pull the forecast values
def pullValues(xmlsoup):
	tempxml = xmlsoup.data.parameters.temperature.findAll('value')
	humidityxml = xmlsoup.data.parameters.humidity.findAll('value')
	temp  = [float(val.text) for val in tempxml]
	humidity = [float(val.text) for val in humidityxml]
	wind = [float(val.text)*1.15078 for val in xmlsoup.data.parameters.findAll('wind-speed')[0].findAll('value')]
	cloudy = [float(val.text) for val in xmlsoup.data.parameters.findAll('cloud-amount')[0].findAll('value')]

	convhazard = xmlsoup.data.parameters.findAll('convective-hazard')
	for kind in convhazard:
		hazardtype = kind.findAll('severe-component')[0]['type']
		if hazardtype == 'hail':
			hail = [float(val.text) for val in kind.findAll('value')]
		else:
			thunderstorm = [float(val.text) for val in kind.findAll('value')]

	precipxml = xmlsoup.data.parameters.findAll('precipitation')
	for kind in precipxml:
		preciptye = kind['type']
		if preciptye == 'liquid':
			rain = [float(val.text)/6 for val in kind.findAll('value')]
		elif preciptye == 'snow':
			snow = [float(val.text) for val in kind.findAll('value')]
		else:
			ice = [float(val.text) for val in kind.findAll('value')]
	predictions = {'temp': temp,'humidity':humidity,'wind':wind,'rain':rain,'snow':snow,'ice':ice,'hail':hail,'thunderstorm':thunderstorm,'cloudy':cloudy}
	return predictions


#Join the different data frames into one
def joinDataFrames(predictions,dt):
	forecasts = pd.DataFrame(dt['datetime1'],columns=['dates'])
	forecasts2 = pd.DataFrame(dt['datetime2'],columns=['dates'])
	forecasts3 = pd.DataFrame(dt['datetime3'],columns=['dates'])
	forecasts4 = pd.DataFrame(dt['datetime4'],columns=['dates'])
	forecasts['drybulb_fahrenheit'] = predictions['temp']
	forecasts['relative_humidity'] = predictions['humidity']
	forecasts['wind_speed'] = predictions['wind']
	#forecasts['CloudCover'] = predictions['cloudy']
	forecasts2['hourly_precip'] = predictions['rain']
	#forecasts2['Snow'] = predictions['snow']
	#forecasts2['Ice'] = predictions['ice']
	#forecasts3['Hail'] = predictions['hail']
	#forecasts4['Probability of Thunderstorm'] = predictions['thunderstorm']
	forecasts = forecasts.set_index('dates')
	forecasts2 = forecasts2.set_index('dates')
	forecasts3 = forecasts3.set_index('dates')
	forecasts4 = forecasts4.set_index('dates')
	forecasts = forecasts.join(forecasts2).join(forecasts3).join(forecasts4)
	forecasts['year'] = [datetime.strptime(dt, "%Y-%m-%dT%H:00:00-05:00").year for dt in forecasts.index.values]
	forecasts['month'] = [datetime.strptime(dt, "%Y-%m-%dT%H:00:00-05:00").month for dt in forecasts.index.values]
	forecasts['day'] = [datetime.strptime(dt, "%Y-%m-%dT%H:00:00-05:00").day for dt in forecasts.index.values]
	forecasts['hour'] = [datetime.strptime(dt, "%Y-%m-%dT%H:00:00-05:00").hour for dt in forecasts.index.values]
	forecasts['datetime'] = [val[:-6] for val in forecasts.index.values]
	#forecasts['datetime'] = forecasts[['year','month','day']].apply(lambda row: '-'.join(map(str, row)), axis=1)
	#forecasts['datetime'] = forecasts['datetime'] +' '+ forecasts['hour'].map(str) +':00'
	forecasts = forecasts.drop(['year','month','day','hour'], 1)
	return forecasts

def formatDataFrame(df_output,wban,latitude,longitude):
	df_output['forecastedDT'] = time.strftime("%x")
	df_output['id'] = df_output['datetime'] + df_output['forecastedDT']#[dat + forecastedDT for dat in df_output.index.values]
	df_output['id'] = df_output['id'].str.replace('-', '').str.replace('/','').str.replace('-','').str.replace(' ','').str.replace(':','')
	df_output = df_output.drop('forecastedDT', 1)
	df_output['latitude'] = latitude
	df_output['longitude'] = longitude
	df_output['wetbulb_fahrenheit'] = np.NaN
	df_output['wban_code'] = wban
	df_output['dewpoint_fahrenheit'] = np.NaN
	#df_output['datetime'] = pd.to_datetime(df_output['datetime'])
	df_output = df_output.reset_index(drop=True)
	#df_output = df_output.set_index('id')
	return df_output

def prep(url):
	request = requests.get(url)
	xmlstring = request.text.encode('utf-8')
	xmlsoup = bs4.BeautifulSoup(xmlstring, 'xml', from_encoding="utf-8")
	return xmlsoup

def wban_df(url,wban):
	xmlsoup = prep(url)
	dt = pullDatetimes(xmlsoup)
	predictions = pullValues(xmlsoup)
	df_output = joinDataFrames(predictions,dt).interpolate()
	df_output = formatDataFrame(df_output,wban,xmlsoup.data.point['latitude'],xmlsoup.data.point['longitude']  )
	return df_output

if __name__ == "__main__":
	prefix = 'http://graphical.weather.gov/xml/SOAP_server/ndfdXMLclient.php?whichClient=NDFDgenMultiZipCode&lat=&lon=&listLatLon=&lat1=&lon1=&lat2=&lon2=&resolutionSub=&listLat1=&listLon1=&listLat2=&listLon2=&resolutionList=&endPoint1Lat=&endPoint1Lon=&endPoint2Lat=&endPoint2Lon=&listEndPoint1Lat=&listEndPoint1Lon=&listEndPoint2Lat=&listEndPoint2Lon=&zipCodeList='
	suffix = '&listZipCodeList=&centerPointLat=&centerPointLon=&distanceLat=&distanceLon=&resolutionSquare=&listCenterPointLat=&listCenterPointLon=&listDistanceLat=&listDistanceLon=&listResolutionSquare=&citiesLevel=&listCitiesLevel=&sector=&gmlListLatLon=&featureType=&requestedTime=&startTime=&endTime=&compType=&propertyName=&product=time-series&begin=2015-03-31T00%3A00%3A00&end=2019-04-19T00%3A00%3A00&Unit=e&temp=temp&qpf=qpf&snow=snow&wspd=wspd&sky=sky&rh=rh&phail=phail&ptotsvrtstm=ptotsvrtstm&iceaccum=iceaccum&Submit=Submit'
	url1 = prefix + '60637' + suffix
	url2 = prefix + '60666' + suffix
	url3 = prefix + '60026' + suffix
	url4 = prefix + '46406' + suffix
	url5 = prefix + '60605' + suffix
	try:
		df_output = wban_df(url1,14819)
	except:
		print '14819 failed'
	try:
		df_output2 = wban_df(url2,94846)
		df_output.append(df_output2,ignore_index=True)
	except:
		print '94846 failed'
	try:
		df_output3 = wban_df(url3,14855)
		df_output.append(df_output3,ignore_index=True)
	except:
		print '14855 failed'
	try:
		df_output4 = wban_df(url4,'04807')
		df_output.append(df_output4,ignore_index=True)
	except:
		print '04807 failed'
	try:
		df_output5 = wban_df(url5,94866)
		df_output.append(df_output5,ignore_index=True)
	except:
		print '94866 failed'

#	df_output = df_output1.append(df_output2,ignore_index=True).append(df_output3,ignore_index=True).append(df_output4,ignore_index=True).append(df_output5,ignore_index=True)
	#cols = ['wind_direction','datetime','report_type','wetbulb_fahrenheit','id','station_type','sky_condition','hourly_precip','drybulb_fahrenheit','latitude','wban_code','old_station_type','visibility','wind_direction_cardinal','sealevel_pressure','weather_types','wind_speed','sky_condition_top','longitude','relative_humidity','dewpoint_fahrenheit','station_pressure']
	cols = ['wind_speed','datetime','relative_humidity','hourly_precip','drybulb_fahrenheit','dewpoint_fahrenheit','wetbulb_fahrenheit','wban_code' ]
	df_output = df_output[cols]
	df_output = df_output.groupby(['datetime'])['wind_speed','relative_humidity','hourly_precip','drybulb_fahrenheit'].mean()
	df_output['datetime'] = [dt.replace('T',' ') for dt in df_output.index]
	df_output = df_output.reset_index(drop = True)
	start = df_output['datetime'].head(1).item()
	end = df_output['datetime'].tail(1).item()
	all_dates = pd.date_range(start,end,freq='H')
	for dt in all_dates:
		if str(dt) not in df_output['datetime'].values:
			bottom = len(df_output)
			df_output.loc[bottom] = np.array([ np.nan,np.nan,np.nan,np.nan,dt ])
	df_output['datetime'] = pd.to_datetime(df_output['datetime'])
	df_output['hournumber'] = [ dt.hour for dt in df_output['datetime'] ]
	df_output['year'] = [ dt.year for dt in df_output['datetime'] ]
	df_output=df_output.sort(['datetime'])
	df_output=df_output.interpolate()
	df_output=df_output.fillna(method='backfill')
	final_joined = df_output
	final_joined['dt'] = final_joined['datetime']
	final_joined = final_joined.drop(['datetime'],1)
	
	
	final_joined.to_csv('forecasts.csv',index=False)
