from WeatherStationReader import WeatherStationReader
from WeatherReader import WeatherReader

reader = WeatherStationReader('../Data/isd-history.csv')
#print(len(reader._stationList))

i = reader._stationList[2000]
#print(i._LON,i._LAT)
i._nearestStations(reader._stationList,radius = 10)# 10 here is the length of radius.
#print(len(i._nearbyStationList))

lon = reader._stationList[2000]._LON
lat = reader._stationList[2000]._LAT
#print(lon,lat)
#print(reader._pointNearestStations(lat,lon,radius = 1000))
lon = lon - 1
lat = lat -1
a,b,c = reader.getWeightsBasedOnLocation(lat,lon,radius = 1000)

print(c)


reportReader = WeatherReader('../Data/ChicagoWeather.csv')
reportReader._weatherReportList[1].printOut()

wban_code_list = ["94846","4807","14819"]

print(wban_code_list)
import datetime
reportTime = datetime.datetime.strptime("2014-01-31T23:49:00", "%Y-%m-%dT%H:%M:%S")
reportList = reportReader.retrieveWeatherReports(wban_code_list,reportTime)

for x in reportList:
    x.printOut()
