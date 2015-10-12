#This python file pulls weather forecast data for Chicago from NOAA. Currently has temperature, humidity, wind speed, rain, snow, ice, hail,
#and probability of a thunderstorm.

import pandas as pd
import requests
import bs4
from datetime import datetime
import time


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
	wind = [float(val.text) for val in xmlsoup.data.parameters.findAll('wind-speed')[0].findAll('value')]
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
			rain = [float(val.text) for val in kind.findAll('value')]
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
	forecasts['CloudCover'] = predictions['cloudy']
	forecasts2['hourly_precip'] = predictions['rain']
	forecasts2['Snow'] = predictions['snow']
	forecasts2['Ice'] = predictions['ice']
	forecasts3['Hail'] = predictions['hail']
	forecasts4['Probability of Thunderstorm'] = predictions['thunderstorm']
	forecasts = forecasts.set_index('dates')
	forecasts2 = forecasts2.set_index('dates')
	forecasts3 = forecasts3.set_index('dates')
	forecasts4 = forecasts4.set_index('dates')
	forecasts = forecasts.join(forecasts2).join(forecasts3).join(forecasts4)
	forecasts['year'] = [datetime.strptime(dt, "%Y-%m-%dT%H:00:00-05:00").year for dt in forecasts.index.values]
	forecasts['month'] = [datetime.strptime(dt, "%Y-%m-%dT%H:00:00-05:00").month for dt in forecasts.index.values]
	forecasts['day'] = [datetime.strptime(dt, "%Y-%m-%dT%H:00:00-05:00").day for dt in forecasts.index.values]
	forecasts['hour'] = [datetime.strptime(dt, "%Y-%m-%dT%H:00:00-05:00").hour for dt in forecasts.index.values]
	forecasts['dt'] = forecasts[['year','month','day']].apply(lambda row: '-'.join(map(str, row)), axis=1)
	forecasts['dt'] = forecasts['dt'] +' '+ forecasts['hour'].map(str) +':00'
	return forecasts


if __name__ == "__main__":
	url = 'http://graphical.weather.gov/xml/SOAP_server/ndfdXMLclient.php?whichClient=NDFDgenMultiZipCode&lat=&lon=&listLatLon=&lat1=&lon1=&lat2=&lon2=&resolutionSub=&listLat1=&listLon1=&listLat2=&listLon2=&resolutionList=&endPoint1Lat=&endPoint1Lon=&endPoint2Lat=&endPoint2Lon=&listEndPoint1Lat=&listEndPoint1Lon=&listEndPoint2Lat=&listEndPoint2Lon=&zipCodeList=60637&listZipCodeList=&centerPointLat=&centerPointLon=&distanceLat=&distanceLon=&resolutionSquare=&listCenterPointLat=&listCenterPointLon=&listDistanceLat=&listDistanceLon=&listResolutionSquare=&citiesLevel=&listCitiesLevel=&sector=&gmlListLatLon=&featureType=&requestedTime=&startTime=&endTime=&compType=&propertyName=&product=time-series&begin=2015-03-31T00%3A00%3A00&end=2019-04-19T00%3A00%3A00&Unit=e&temp=temp&qpf=qpf&snow=snow&wspd=wspd&sky=sky&rh=rh&phail=phail&ptotsvrtstm=ptotsvrtstm&iceaccum=iceaccum&Submit=Submit'
	request = requests.get(url)
	xmlstring = request.text.encode('utf-8')
	xmlsoup = bs4.BeautifulSoup(xmlstring, 'xml', from_encoding="utf-8")

	dt = pullDatetimes(xmlsoup)
	predictions = pullValues(xmlsoup)
	df_output = joinDataFrames(predictions,dt).interpolate()
	df_output['forecastedDT'] = time.strftime("%x")
	df_output['uniqueID'] = df_output['dt'] + df_output['forecastedDT']#[dat + forecastedDT for dat in df_output.index.values]
	df_output['location'] = xmlsoup.data.point['latitude'] + ',' + xmlsoup.data.point['longitude']
	df_output = df_output.reset_index(drop=True)
	df_output = df_output.set_index('uniqueID')
	df_output.to_csv('forecasts.csv')