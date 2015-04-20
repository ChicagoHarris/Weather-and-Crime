#This python file pulls weather forecast data for Chicago from NOAA. Currently has temperature, humidity, wind speed, and precipitation

import pandas as pd
import requests
import bs4


url = 'http://graphical.weather.gov/xml/SOAP_server/ndfdXMLclient.php?whichClient=NDFDgenMultiZipCode&lat=&lon=&listLatLon=&lat1=&lon1=&lat2=&lon2=&resolutionSub=&listLat1=&listLon1=&listLat2=&listLon2=&resolutionList=&endPoint1Lat=&endPoint1Lon=&endPoint2Lat=&endPoint2Lon=&listEndPoint1Lat=&listEndPoint1Lon=&listEndPoint2Lat=&listEndPoint2Lon=&zipCodeList=60638&listZipCodeList=&centerPointLat=&centerPointLon=&distanceLat=&distanceLon=&resolutionSquare=&listCenterPointLat=&listCenterPointLon=&listDistanceLat=&listDistanceLon=&listResolutionSquare=&citiesLevel=&listCitiesLevel=&sector=&gmlListLatLon=&featureType=&requestedTime=&startTime=&endTime=&compType=&propertyName=&product=time-series&begin=2015-03-31T00%3A00%3A00&end=2019-04-02T00%3A00%3A00&Unit=e&temp=temp&qpf=qpf&snow=snow&wspd=wspd&sky=sky&rh=rh&Submit=Submit'
request = requests.get(url)
xmlstring = request.text.encode('utf-8')
xmlsoup = bs4.BeautifulSoup(xmlstring, 'xml', from_encoding="utf-8")
data = xmlsoup.findAll('data')
datetime = xmlsoup.data.findAll('time-layout')
datetime1 = [date.text for date in datetime[0].findAll('start-valid-time')]
datetime2 = [date.text for date in datetime[1].findAll('start-valid-time')]

forecasts = pd.DataFrame(datetime1,columns=['Datetime'])
forecasts2 = pd.DataFrame(datetime2,columns=['Datetime'])


tempxml = xmlsoup.data.parameters.temperature.findAll('value')
humidityxml = xmlsoup.data.parameters.humidity.findAll('value')
precipxml = xmlsoup.data.parameters.precipitation.findAll('value')
wind = [speed.text for speed in xmlsoup.data.parameters.findAll('wind-speed')[0].findAll('value')]

temperature = []
humidity = []
precipitation =[]

for prediction in tempxml:
	temperature.append(float(prediction.text))

for prediction in humidityxml:
	humidity.append(float(prediction.text))

for prediction in precipxml:
	precipitation.append(float(prediction.text))

forecasts['Temperature'] = temperature
forecasts['Humidity'] = humidity
forecasts['WindSpeed'] = wind
forecasts = forecasts.set_index('Datetime')
forecasts2 = forecasts2.set_index('Datetime')
forecasts2['Precipitation'] = precipitation
forecasts = forecasts.join(forecasts2)
print forecasts