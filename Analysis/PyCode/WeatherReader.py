from __future__ import division, print_function, absolute_import
import numpy as np
import csv
from Weather import Weather

class WeatherReader():
    def __init__(self,fileName):
        self._weatherReportList = None
        self._initializeWeatherReport(fileName)


    def _initializeWeatherReport(self,filename):
        """
        Read the Station Information from file.
        Parameters
        -----------
        filename: string, the location of the weather station csv file.
        
        Returns
        -----------
        No return. Will initialize the weather station list.
        """
        weatherReportList = []
        field = []
        with open(filename,'rU') as csvfile:
            reader = csv.reader(csvfile,delimiter = ',')
            counter = 0;
            for row in reader:
                counter= counter+1
                if(counter == 1):
                    field = row[:]
                else:
                    #pass
                    weatherReportList.append([row[field.index('wban_code')],row[field.index('datetime')],
                                              row[field.index('wind_speed')],row[field.index('sky_condition')],
                                              row[field.index('visibility')],row[field.index('relative_humidity')],
                                              row[field.index('hourly_precip')],row[field.index('drybulb_fahrenheit')],
                                              row[field.index('wetbulb_fahrenheit')],row[field.index('dewpoint_fahrenheit')],
                                              row[field.index('station_pressure')],row[field.index('weather_types')]])
        
        allWeatherReports = []
        for weatherReport in weatherReportList:
            allWeatherReports.append(Weather(weatherReport))
        self._weatherReportList = allWeatherReports


    def retrieveWeatherReports(self,wban_code_list,reportTime):

        reportTimeList = [None for i in range(len(wban_code_list))]
        reportList = [None for i in range(len(wban_code_list))]
        for weatherReport in self._weatherReportList:
            if weatherReport._weatherStation in wban_code_list:
                index = wban_code_list.index(weatherReport._weatherStation)
                if reportTimeList[index]==None:
                    reportTimeList[index] = weatherReport._dateTime
                    reportList[index] = weatherReport
                elif abs(reportTimeList[index] - reportTime)>abs(weatherReport._dateTime - reportTime):
                    reportTimeList[index] = weatherReport._dateTime
                    reportList[index] = weatherReport
                else:
                    continue
        print(reportList)
        return reportList
