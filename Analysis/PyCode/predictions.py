#This file reformats the prediction csv file into a format that is useful for the engineers to feed into the website.
import csv
import time
import datetime

with open('samplePredict.csv') as f:
    reader = csv.reader(f)
    reader.next()
    headers = ['UniqueID','CensusTract','HourNumber','Date','E(ViolentCrime)','S.E. ViolentCrime','E(Robbery)','S.E. Robbery','E(Assault)','S.E. Assault', 'E(Property Crime)','S.E. Property Crime','E(AllCrimes)','S.E. AllCrimes',
                'E(ViolentCrime|Weather)','S.E. ViolentCrime|Weather','E(Robbery|Weather)','S.E. Robbery|Weather','E(Assault|Weather)','S.E. Assault|Weather', 'E(Property Crime|Weather)','S.E. Property Crime|Weather','E(AllCrimes|Weather)',
                'S.E. AllCrimes|Weather','Delta ViolentCrime','Delta Robbery', 'Delta Assault', 'Delta Property', 'Delta All Crimes']


    data=[]
    data.append(headers)
    #Today's date will be used as part of the unique id
    runDT = time.strftime("%x")
    for line in reader:
        row = []
        #Pull out year, hour and strip off the extra zeroes
        dt = datetime.datetime.strptime(line[3], '%Y-%m-%d %H:%M:%S')
        year = dt.year
        hour = dt.hour
        day = datetime.datetime.strftime(dt,'%m/%d/%y')
        uniqueid = line[0]+day + runDT
        uniqueid = uniqueid.replace("-", "").replace('/','').replace(':','').replace(' ','')
        violentweather = line[22]
        #Zeroes are being used as placeholders for now
        row = [uniqueid,line[0], hour, day, 0,0,0,0,0,0,0,0,0,0, violentweather,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

        data.append( row )

with open("mockup.csv", "wb") as f:
    writer = csv.writer(f)
    writer.writerows(data)