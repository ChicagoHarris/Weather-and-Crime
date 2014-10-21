from WeatherStationReader import WeatherStationReader

reader = WeatherStationReader('../Data/isd-history.csv')
print(len(reader._stationList))

for i in reader._stationList:
    i._nearestStations(reader._stationList,neighborNum = 20)
    print(len(i._nearbyStationList))
