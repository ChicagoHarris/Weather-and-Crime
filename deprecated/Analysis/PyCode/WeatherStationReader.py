from __future__ import division, print_function, absolute_import
import numpy as np
import csv
from WeatherStation import WeatherStation

# Author: Jiajun Shen (jiajun@cs.uchicago.edu)
#
#


class WeatherStationReader():
    def __init__(self,fileName):
        self._stationList = None        
        self._initializeWeatherStation(fileName)

    def _initializeWeatherStation(self,filename):
        """
        Read the Station Information from file.
        Parameters
        -----------
        filename: string, the location of the weather station csv file.
        
        Returns
        -----------
        No return. Will initialize the weather station list.
        """
        stationList = []
        
        with open(filename,'rb') as csvfile:
            reader = csv.reader(csvfile,delimiter = ',')
            for row in reader:
                stationList.append(row[:])
        allWeatherStations = []
        for i in stationList[1:]:
            if i[1] == "99999":
                continue
            allWeatherStations.append(WeatherStation(i))
            
        self._stationList = allWeatherStations
    

    def _pointNearestStations(self, lat, lon, radius = None,neighborNum = None):
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
        
        allWeatherStations = self._stationList
        nearbyStationList = []
        distanceOfNearbyStation = []
        if radius != None:
            for station in allWeatherStations:
                distance = station._pointDistanceTo(lat, lon)
                if(distance<=radius):
                    nearbyStationList.append(station)
                    distanceOfNearbyStation.append(distance)
            print(len(distanceOfNearbyStation))
            distanceOfNearbyStation = np.array(distanceOfNearbyStation)
            nearbyStationList = np.array(nearbyStationList)[np.argsort(distanceOfNearbyStation)]
            distanceOfNearbyStation = np.sort(distanceOfNearbyStation)



        if neighborNum != None:
            distanceList = []
            for i in range(len(allWeatherStations)):
                distanceList.append(allWeatherStations[i]._pointDistanceTo(lat, lon))
            distanceList = np.array(distanceList,dtype = np.double)
            nearbyStationList = np.array(allWeatherStations)[np.argsort(distanceList)[:neighborNum]]
            distanceOfNearbyStation = distanceList[np.argsort(distanceList)[:neighborNum]]
        
        return nearbyStationList,distanceOfNearbyStation
    
    def getWeightsBasedOnLocation(self, lat, lon, radius = None, neighborNum = None, powerParameter = 2):
        print("====================")
        nearbyStationArray, distanceOfNearbyStation = self._pointNearestStations(lat, lon, radius, neighborNum)
#        print(distanceOfNearbyStation)
        if(distanceOfNearbyStation[0] == 0):
            return np.array(nearbyStationArray[0]),np.array(distanceOfNearbyStation[0]),np.array(1)

        weights = np.power(distanceOfNearbyStation, -powerParameter)
        weights = weights / np.sum(weights)
        print("================")
        print(weights)
        return nearbyStationArray, distanceOfNearbyStation, weights



