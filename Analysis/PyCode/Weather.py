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
        if rawRecord != None:
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
        self._skyCondition = transferSkyCondition(rawRecord[3])
        self._visibility = checkMissing(rawRecord[4],float)
        self._relativeHumidity = checkMissing(rawRecord[5],float)
        self._hourlyPrecip = checkRobust(rawRecord[6],float)
        self._drybulbFahren = checkMissing(rawRecord[7],float)
        self._wetbulbFahren = checkMissing(rawRecord[8],float)
        self._dewpointFahren = checkMissing(rawRecord[9],float)
        self._stationPressure = checkMissing(rawRecord[10],float)
        self._parseWeatherType(rawRecord[11])

    def printOut(self):
        print(self.outputResult())

    def outputResult(self):
        result = [
        #self._weatherStation,
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
        self._weatherType]
        return result

    def _parseWeatherType(self, rawRecord):
        self._thunderStorm = (rawRecord.find("TS")>0)
        self._hail = (rawRecord.find("GR")>0)
        self._rain = (rawRecord.find("RA")>0)
        self._drizzle = (rawRecord.find("DZ")>0)
        self._snow = (rawRecord.find("SN")>0)
        self._snowGrains = (rawRecord.find("SG")>0)
        self._smallHail = (rawRecord.find("GS")>0)
        self._icePellets = (rawRecord.find("PL")>0)
        self._iceCrystals = (rawRecord.find("IC")>0)
        self._heavyfog = (rawRecord.find("+")>0 and rawRecord.find("FG")>0)
        self._fog = (rawRecord.find("FG")>0)
        self._mist = (rawRecord.find("BR")>0)
        self._haze = (rawRecord.find("HZ")>0)
        self._smoke = (rawRecord.find("FU")>0)
        self._wideSpreadDust = (rawRecord.find("DU")>0)
        self._dustStorm = (rawRecord.find("DS")>0)
        self._sand = (rawRecord.find("SA")>0)
        self._sandStorm = (rawRecord.find("SS")>0)
        self._shower = (rawRecord.find("SH")>0)
        self._freezing = (rawRecord.find("FZ")>0)
        self._blowing = (rawRecord.find("BL")>0)
        self._weatherType = [
        self._thunderStorm,
        self._hail,
        self._rain,
        self._drizzle,
        self._snow,
        self._snowGrains,
        self._smallHail,
        self._icePellets,
        self._iceCrystals,
        self._heavyfog,
        self._fog,
        self._mist,
        self._haze,
        self._smoke,
        self._wideSpreadDust,
        self._dustStorm,
        self._sand,
        self._sandStorm,
        self._shower,
        self._freezing,
        self._blowing]

def checkRobust(rawRecord, resultType):
    if(rawRecord != None and rawRecord != ""):
        return resultType(rawRecord)
    else:
        return resultType(0)

def checkMissing(rawRecord, resultType):
    if(rawRecord != None and rawRecord != ""):
        return resultType(rawRecord)
    else:
        return resultType(-99999)# This indicates data missing. Other good idea?

def transferSkyCondition(rawRecord):
    cloudCoverage = None
    metar = rawRecord[:3]
    if rawRecord[:3] == "CLR":
        cloudCoverage = 0
    elif rawRecord[:3] == "FEW":
        height = int(rawRecord[3:6])
        if(height > 100):
            cloudCoverage = 1
        else:
            cloudCoverage = 2
    elif rawRecord[:3] == "SCT":
        height = int(rawRecord[3:6])
        if(height > 100):
            cloudCoverage = 3
        else:
            cloudCoverage = 4
    elif rawRecord[:3] == "BKN":
        height = int(rawRecord[3:6]) 
        if(height > 200):
            cloudCoverage = 5
        elif(height > 100):
            cloudCoverage = 6
        else:
            cloudCoverage = 7
    elif rawRecord[:3] == "OVC":
        cloudCoverage = 8
    elif rawRecord[:2] == "VV":
        cloudCoverage = 9
        metar = rawRecord[:2]
    elif rawRecord[0] == "M":
        cloudCoverage = -99999
        metar = "M"

    return cloudCoverage


        
def reWeightIfMiss(valueList, weightList):
    if -99999 not in valueList:
        resultValue = np.sum(np.array(valueList) * np.array(weightList))
        return valueList, weightList,resultValue
    else:
        index = np.where(np.array(valueList) != -99999)[0]
        valueList = valueList[index]
        weightList = weightList[index]
        weightList = weightList / sum(weightList)
        resultValue = np.sum(np.array(valueList) * np.array(weightList))
        return valueList, weightList,resultValue

def weightReport(weightList, reportList, dateTime):
    print(len(weightList),len(reportList))
    assert(len(weightList) == len(reportList)), 'the length of the weight list is not equal to the report list'
    windSpeedReport = reWeightIfMiss([report._windSpeed for report in reportList],weightList)
    skyConditionReport = reWeightIfMiss([report._skyCondition for report in reportList],weightList)
    visibilityReport = reWeightIfMiss([report._visibility for report in reportList],weightList)
    relativeHumidityReport = reWeightIfMiss([report._relativeHumidity for report in reportList],weightList)
    hourlyPrecipReport = reWeightIfMiss([report._hourlyPrecip for report in reportList],weightList)
    drybulbFahrenReport = reWeightIfMiss([report._drybulbFahren for report in reportList],weightList)
    wetbulbFahrenReport = reWeightIfMiss([report._wetbulbFahren for report in reportList],weightList)
    dewpointFahrenReport = reWeightIfMiss([report._dewpointFahren for report in reportList],weightList)
    stationPressureReport = reWeightIfMiss([report._stationPressure for report in reportList],weightList)
    weatherTypeReport = np.matrix(weightList) * np.matrix([np.array(report._weatherType) for report in reportList])
    weatherTypeReport = (weatherTypeReport>0.3).tolist()[0]
    return Weather(rawRecord = None, weatherStation = "generatedReports",dateTime = dateTime, windSpeed = windSpeedReport[2],skyCondition = skyConditionReport[2],visibility = visibilityReport[2],relativeHumidity= relativeHumidityReport[2],hourlyPrecip = hourlyPrecipReport[2],drybulbFahren = drybulbFahrenReport[2],wetbulbFahren = wetbulbFahrenReport[2],dewpointFahren = dewpointFahrenReport[2],stationPressure = stationPressureReport[2],weatherType = weatherTypeReport)

    




















    
    
        
