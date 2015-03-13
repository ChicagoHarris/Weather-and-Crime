from WeatherStationReader import WeatherStationReader
from WeatherReader import WeatherReader
import datetime
import csv 
import sys
import numpy as np

def filterWeatherStationWeights(nearbyStations, nearbyDistance, stationWeights):
    """
    This is a heuristic function which helps to filter out weather stations that are not in Chicago land. Since we only have weather reports from Chicago, getting the weights from other weather stations makes no sense.
    We don't need this in the future.
    """
    filteredNearbyStations = []
    filteredNearbyDistance = []
    filteredStationWeights = []
    ChicagoWeatherStation = ["4807","4831","14819","94846"]
    print(stationWeights)
    print([x._WBAN for x in nearbyStations])
    print(nearbyDistance)
    print("===================")
    for i in range(len(nearbyStations)):
        if nearbyStations[i]._WBAN in ChicagoWeatherStation:
            filteredNearbyStations.append(nearbyStations[i])
            filteredNearbyDistance.append(nearbyDistance[i])
            filteredStationWeights.append(stationWeights[i])
    print(type(np.array(filteredStationWeights)))
    filterWeatherStationWeights = np.array(filteredStationWeights)
    sumAll = np.sum(filterWeatherStationWeights)
    print(sumAll)
    print("===============")
    filteredStationWeights = np.array(filterWeatherStationWeights)/sumAll 
    return filteredNearbyStations, filteredNearbyDistance, filteredStationWeights


reader = WeatherStationReader('../Data/isd.csv')
filename = '../Data/CensusTractHour.csv'
csv.field_size_limit(sys.maxsize)

censusUnitList = []
with open(filename,'rb') as csvfile:
    censusreader = csv.reader(csvfile,delimiter = ',')
    counter = 0;
    for row in censusreader:
        counter = counter + 1
        if(counter == 1):
            continue
        startTime = datetime.datetime.strptime(row[2], "%Y-%m-%d %H:%M:%S")
        endTime = datetime.datetime.strptime(row[3],"%Y-%m-%d %H:%M:%S")
        censusUnitList.append([row[0],startTime,endTime,float(row[5]),float(row[6])])

#print(len(reader._stationList))

i = reader._stationList[2]
#print(i._LON,i._LAT)
i._nearestStations(reader._stationList,radius = 10)# 10 here is the length of radius.
#print(len(i._nearbyStationList))

lon = reader._stationList[2]._LON
lat = reader._stationList[2]._LAT
#print(lon,lat)
#print(reader._pointNearestStations(lat,lon,radius = 1000))
lon = lon - 1
lat = lat -1
a,b,c = reader.getWeightsBasedOnLocation(lat,lon,radius = 1000)

print(c)


reportReader = WeatherReader('../Data/ChicagoWeather.csv')
reportReader._weatherReportList[1].printOut()

wban_code_list = ["94846","4807","14819"]

weightList = [0.5,0.3,0.2]

print(wban_code_list)
import datetime
reportTime = datetime.datetime.strptime("2014-01-31T23:49:00", "%Y-%m-%dT%H:%M:%S")
reportList = reportReader.retrieveWeatherReports(wban_code_list,reportTime)
from Weather import weightReport

weightedReport = weightReport(weightList,reportList,reportTime)

for x in reportList:
    x.printOut()

weightedReport.printOut()


censusListLen = len(censusUnitList)

with open('censusUnitJointWeather.csv', 'wb') as csvfile:
    writer = csv.writer(csvfile, delimiter=',')
    writer.writerow(["censusID","startTime","endTime","lon","lat","weatherReportTime","windSpeed","skycondition", "visibility","relativeHumidity","hourlyPrecip","drybulbFahren","wetbulbFahren", "dewPointFahren", "stationPressure", "thunderstorm", "hail", "rain", "drizzle", "snow", "snowgrains", "small hail", "ice pellets", "icecrystals", "heavyfog", "fog", "mist", "haze", "smoke", "widespreaddust", "duststorm", "sand", "sandstorm","shower", "freezing", "blowing"])
    for i in range(censusListLen):
        originalReport = reader.getWeightsBasedOnLocation(censusUnitList[i][4],censusUnitList[i][3],neighborNum = 3)
        a,b,c = filterWeatherStationWeights(originalReport[0],originalReport[1],originalReport[2])
        print(b)
        wban_code_list = [station._WBAN for station in a]
        midTime = (censusUnitList[i][2] - censusUnitList[i][1])/2 + censusUnitList[i][1]
        #midTime = //2)
        print(censusUnitList[i][1],censusUnitList[i][2],midTime)
        reportList = reportReader.retrieveWeatherReports(wban_code_list,midTime)
        weightedReport = weightReport(c,reportList,midTime)
        print("=================================")
        for report in reportList:
            report.printOut()
        print("---------------------------------")
        weightedReport.printOut()
        resultRow = [censusUnitList[i][0],censusUnitList[i][1],censusUnitList[i][2],censusUnitList[i][3],censusUnitList[i][4]]
        weatherReport = weightedReport.outputResult()
        for i in weatherReport:
            if isinstance(i,list):
                for j in i:
                    resultRow.append(j)
            else:
                resultRow.append(i)
        writer.writerow(resultRow)

