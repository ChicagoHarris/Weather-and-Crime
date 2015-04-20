#This python file pulls weather forecast data for Chicago from NOAA. Currently has temperature, humidity, wind speed, rain, snow, ice, hail,
#and probability of a thunderstorm.

import pandas as pd
import requests
import bs4


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


def joinDataFrames(predictions,datetime):
	#temp,humidity,wind,rain,snow,ice,hail,thunderstorm = predictions.values()
	#datetime1,datetime2,datetime3,datetime4 = datetime.values()

	forecasts = pd.DataFrame(datetime['datetime1'],columns=['Datetime'])
	forecasts2 = pd.DataFrame(datetime['datetime2'],columns=['Datetime'])
	forecasts3 = pd.DataFrame(datetime['datetime3'],columns=['Datetime'])
	forecasts4 = pd.DataFrame(datetime['datetime4'],columns=['Datetime'])
	forecasts['Temperature'] = predictions['temp']
	forecasts['Humidity'] = predictions['humidity']
	forecasts['WindSpeed'] = predictions['wind']
	forecasts['CloudCover'] = predictions['cloudy']
	forecasts2['Rain'] = predictions['rain']
	forecasts2['Snow'] = predictions['snow']
	forecasts2['Ice'] = predictions['ice']
	forecasts3['Hail'] = predictions['hail']
	forecasts4['Probability of Thunderstorm'] = predictions['thunderstorm']
	forecasts = forecasts.set_index('Datetime')
	forecasts2 = forecasts2.set_index('Datetime')
	forecasts3 = forecasts3.set_index('Datetime')
	forecasts4 = forecasts4.set_index('Datetime')
	forecasts = forecasts.join(forecasts2).join(forecasts3).join(forecasts4)
	return forecasts


if __name__ == "__main__":
	url = 'http://graphical.weather.gov/xml/SOAP_server/ndfdXMLclient.php?whichClient=NDFDgenMultiZipCode&lat=&lon=&listLatLon=&lat1=&lon1=&lat2=&lon2=&resolutionSub=&listLat1=&listLon1=&listLat2=&listLon2=&resolutionList=&endPoint1Lat=&endPoint1Lon=&endPoint2Lat=&endPoint2Lon=&listEndPoint1Lat=&listEndPoint1Lon=&listEndPoint2Lat=&listEndPoint2Lon=&zipCodeList=60637&listZipCodeList=&centerPointLat=&centerPointLon=&distanceLat=&distanceLon=&resolutionSquare=&listCenterPointLat=&listCenterPointLon=&listDistanceLat=&listDistanceLon=&listResolutionSquare=&citiesLevel=&listCitiesLevel=&sector=&gmlListLatLon=&featureType=&requestedTime=&startTime=&endTime=&compType=&propertyName=&product=time-series&begin=2015-03-31T00%3A00%3A00&end=2019-04-19T00%3A00%3A00&Unit=e&temp=temp&qpf=qpf&snow=snow&wspd=wspd&sky=sky&rh=rh&phail=phail&ptotsvrtstm=ptotsvrtstm&iceaccum=iceaccum&Submit=Submit'
	request = requests.get(url)
	xmlstring = request.text.encode('utf-8')
	xmlsoup = bs4.BeautifulSoup(xmlstring, 'xml', from_encoding="utf-8")

	datetime = pullDatetimes(xmlsoup)
	predictions = pullValues(xmlsoup)
	df_output = joinDataFrames(predictions,datetime)

	df_output.to_csv('forecasts.csv')
