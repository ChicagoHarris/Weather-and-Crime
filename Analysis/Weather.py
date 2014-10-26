from __future__ import division, print_function, absolute_import
import numpy as np
import csv
import datetime

class Weather():
    def __init__(self, rawRecord = None, weatherStation = None, dateTime = None, windSpeed = None, skyCondition = None, visibility = None, relativeHumidity = None, hourlyPrecip = None, drybulbFahren = None, wetbulbFahren = None, dewpointFahren = None, stationPressure = None, weatherType = None):
        self._weatherStation = weatherStation
        self._dateTime = dateTime
        self._windSpeed = windSpeed
        self._skyCondition = skyCondition
        self._visibility = visibility
        self._relativeHumidity = relativeHumidity
        self._hourlyPrecip = hourlyPrecip
        self._drybulbFahren = drybulbFahren
        self._wetbulbFahren = wetbulbFahren
        self._dewpointFahren = dewpointFahren
        self._stationPressure = stationPressure
        self._weatherType = weatherType
        self._initializeWeatherReport(rawRecord)

    def _initializeWeatherReport(self, rawRecord):
        """
        Parameters
        -----------------
        rawRecord: string, the raw record of this weather report given by the csv file

    

        Return:
        ----------------
        Essential Information we need for one Weather Report
        """
        #print(rawRecord) 
        self._weatherStation = rawRecord[0]
        self._dateTime = datetime.datetime.strptime(rawRecord[1], "%Y-%m-%dT%H:%M:%S")
        self._windSpeed = checkRobust(rawRecord[2],float)
        self._skyCondition = checkRobust(rawRecord[3],str)
        self._visibility = checkRobust(rawRecord[4],float)
        self._relativeHumidity = checkRobust(rawRecord[5],float)
        self._hourlyPrecip = checkRobust(rawRecord[6],float)
        self._drybulbFahren = checkRobust(rawRecord[7],float)
        self._wetbulbFahren = checkRobust(rawRecord[8],float)
        self._dewpointFahren = checkRobust(rawRecord[9],float)
        self._stationPressure = checkRobust(rawRecord[10],float)
        self._weatherType = checkRobust(rawRecord[11],str)

    def printOut(self):
        print([
        self._weatherStation,
        self._dateTime,
        self._windSpeed,
        self._skyCondition,
        self._visibility,
        self._relativeHumidity,
        self._hourlyPrecip,
        self._drybulbFahren,
        self._wetbulbFahren,
        self._dewpointFahren,
        self._stationPressure,
        self._weatherType])


def checkRobust(rawRecord, resultType):
    if(rawRecord != None and rawRecord != ""):
        return resultType(rawRecord)
    else:
        return resultType(0)


def weightReport(weightList, reportList):
    assert(len(weightList) == len(reportList)), 'the length of the weight list is not equal to the report list'
    
        
