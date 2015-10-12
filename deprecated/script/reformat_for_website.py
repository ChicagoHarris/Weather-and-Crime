import pandas as pd
import time
import datetime

df = pd.read_csv('final_output.csv')
df.columns = ['CensusTract','Date','HourNumber','Wind Speed','Drybulb Fahrenheit','Hourly Precip','Relative Humidity','Robbery -E','Robbery Binary','Assault -E','Assault Binary','Violent Crime -E','Shooting Binary']
df.drop(['Robbery Binary','Violent Crime Binary','Assault Binary'],inplace=True)
df['ID'] = df['CensusTract'].astype(str) + df['Date'].astype(str) + time.strftime("%x")
df['ID'] = df['ID'].str.replace('/','')
df['Latitude'] = 41.94
df['Longitude'] = -87.69
cols = ['ID','CensusTract',	'HourNumber','Date', 'Robbery -E','Wind Speed', 'Relative Humidity','Hourly Precip','Drybulb Fahrenheit','Latitude','Longitude']
df = df[cols]
df.to_csv('final_output.csv',index=False)