from __future__ import division, print_function, absolute_import
import numpy as np
import csv
from WeatherStation import WeatherStation

# Author: Jiajun Shen (jiajun@cs.uchicago.edu)
#
#


class WeatherStationReader():
    def __init__(self,fileName):
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
        
        allWeatherStations = self.stationList
        nearbyStationList = []
        distanceOfNearbyStation = []
        if radius != None:
            for station in allWeatherStations:
                distance = station._pointDistanceTo(station, lat, lon)
                if(distance<=radius):
                    nearbyStationList.append(station)
                    distanceOfNearbyStation.append(distance)
            distanceOfNearbyStation = np.array(distanceOfNearbyStation)
            nearbyStationList = np.array(nearbyStationList)[np.argsort(distanceOfNearbyStation)]
            distanceOfNearbyStation = np.sort(distanceOfNearbyStation)



        if neighborNum != None:
            distanceList = []
            for i in range(len(allWeatherStations)):
                distanceList.append(allWeatherStations[i]._distanceTo(lat, lon))
            distanceList = np.array(distanceList,dtype = np.double)
            nearbyStationList = np.array(allWeatherStations)[np.argsort(distanceList)[:neighborNum]]
            distanceOfNearbyStation = distanceList[:neighborNum]
        
        return nearbyStationList,distanceOfNearbyStation
    
    def getWeightsBasedOnLocation(self, lat, lon, radius = None, neighborNum = None, powerParameter = 2):
        nearbyStationArray, distanceOfNearbyStation = self._pointNearestStations(lat, lon, radius, neighborNum)
        weights = numpy.power(distanceOfNearbyStation, -powerParameter)
        weights = weights / numpy.sum(weights)
        return nearbyStationArray, distanceOfNearbyStation, weights



