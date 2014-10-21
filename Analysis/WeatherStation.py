import numpy as np
import csv
import math as Math
# Author: Jiajun Shen (jiajun@cs.uchicago.edu)
#
#


def deg2rad(deg):
    return deg * (Math.pi/180)

class WeatherStation():
    def __init__(self,rawRecord):
        self._initializeWeatherStation(rawRecord)
        self._nearbyStationList = None
        self._distanceOfNearbyStations = None
        
        
    def _initializeWeatherStation(self,rawRecord):
        """
        Parameters
        --------------
        rawRecord: string, the raw record of this weather station given by the csv file

        Return:
        --------------
        Essenstial Information we need for a Weather Station.
        """
        self._USAF = rawRecord[0]
        self._WBAN = rawRecord[1]
        self._StationName = rawRecord[2]
        if(rawRecord[6]!=""):
            self._LAT = float(rawRecord[6])
        else:
            self._LAT = None
        if(rawRecord[7]!=""):
            self._LON = float(rawRecord[7])
        else:
            self._LON = None

    def _distanceTo(self,stationB):
        """
        Parameters
        ------------------
        stationB: WeatherStation.


        Return:
        ------------------
        The distance between current weather station to the given weather station.
        """
        
        lat1 = self._LAT
        lon1 = self._LON
        lat2 = stationB._LAT
        lon2 = stationB._LON
        if lat1 == None or lon1 == None or lat2 == None or lon2 == None:
            return float("inf")
        R = 6371  #Radius of the earth in km
        deltaLat = deg2rad(lat2-lat1);
        deltaLon = deg2rad(lon2-lon1); 
        a = Math.sin(deltaLat/2) * Math.sin(deltaLat/2) + Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * Math.sin(deltaLon/2) * Math.sin(deltaLon/2)
        c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)); 
        d = R * c; # Distance in km
        return d

    def _nearestStations(self,allWeatherStations, radius = None,neighborNum = None):
        """
        Parameters
        -----------------------------
        allWeatherStations: list of Weather stations. 
        
        radius: double, default = None. If radius != None, the nearest stations are those stations have distance less than radius to current weather station
        
        neighborNum: double, default = None. If neighborNum != None, the nearest stations are nearest neighborNum weather stations.

        Return
        -----------------------------
        a list of weather stations ordered by the distance to self, and a list of distances which is the distances to the weather stations accordingly.
        """
        nearbyStationList = []
        distanceOfNearbyStation = []
        if radius != None:
            for station in allWeatherStations:
                distance = self._distanceTo(station)
                if(distance<=radius):
                    nearbyStationList.append(station)
                    distanceOfNearbyStation.append(distance)
            distanceOfNearbyStation = np.array(distanceOfNearbyStation)
            nearbyStationList = np.array(nearbyStationList)[np.argsort(distanceOfNearbyStation)]
            distanceOfNearbyStation = np.sort(distanceOfNearbyStation)



        if neighborNum != None:
            distanceList = []
            for i in range(len(allWeatherStations)):
                distanceList.append(self._distanceTo(allWeatherStations[i]))
            distanceList = np.array(distanceList,dtype = np.double)
            nearbyStationList = np.array(allWeatherStations)[np.argsort(distanceList)[:neighborNum]]
            distanceOfNearbyStation = distanceList[:neighborNum]
        


        self._nearbyStationList = nearbyStationList
        self._distanceOfNearbyStation = distanceOfNearbyStation


        return nearbyStationList,distanceOfNearbyStation

    
