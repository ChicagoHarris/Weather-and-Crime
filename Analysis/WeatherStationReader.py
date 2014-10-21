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
