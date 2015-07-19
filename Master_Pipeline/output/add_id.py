#This file will finish any formatting for the website by adding unique ids and creating placeholder values for variables that are missing.

import pandas as pd
df = pd.read_csv('prediction_robbery_count.csv')
df_assault = pd.read_csv('prediction_assault_count.csv')
df_shooting = pd.read_csv('prediction_shooting_count.csv')

df['dt'] = pd.to_datetime(df['dt'])
df['id'] = df['census_tra'].astype(str)+[dt.strftime('%Y%m%d') for dt in df['dt']]+df['hournumber'].astype(str)
df['ViolentCrime -E'] =df_shooting['V1'].values.round(decimals=3)
df['ViolentCrime -S.E.'] = 0
df['Assault -E'] = df_assault['V1'].values.round(decimals=3)
df['Assault -S.E.'] = 0
#df['PropertyCrime -E'] = 0
#df['PropertyCrime -S.E.'] = 0
df['Robbery -E'] = df['prediction'].round(decimals=3)
df['Robbery -S.E.'] = 0
df['AllCrimes -E'] = 0
df['AllCrimes -S.E.'] = 0
df['ViolentCrime|Weather -E'] = df_shooting['V1'].values.round(decimals=3)
df['ViolentCrime|Weather -S.E.'] = 0
df['Assault|Weather -E'] = df_assault['V1'].values.round(decimals=3)
df['Assault|Weather -S.E.'] = 0
#df['PropertyCrime|Weather -E'] = 0
#df['PropertyCrime|Weather -S.E.'] = 0
df['Robbery|Weather -E'] = df['prediction'].round(decimals=3)
df = df.drop(['prediction','predictionBinary'],1)
df['Robbery|Weather -S.E.'] = 0
df['AllCrimes|Weather -E'] = 0
df['AllCrimes|Weather -S.E.'] = 0
df['Robbery Delta'] = df['Robbery|Weather -E'] - df['Robbery -E']
df['Assault Delta'] = df['Assault|Weather -E'] - df['Assault -E']
df['ViolentCrime Delta'] = df['ViolentCrime|Weather -E'] - df['ViolentCrime -E']
#df['PropertyCrime Delta'] = df['PropertyCrime|Weather -E'] - df['PropertyCrime -E']
df['AllCrimes Delta'] = df['AllCrimes|Weather -E'] - df['AllCrimes -E']



cols = ['id','census_tra','dt','hournumber','ViolentCrime -E','ViolentCrime -S.E.','Assault -E','Assault -S.E.','Robbery -E','Robbery -S.E.','AllCrimes -E','AllCrimes -S.E.','ViolentCrime|Weather -E','ViolentCrime|Weather -S.E.','Assault|Weather -E','Assault|Weather -S.E.','Robbery|Weather -E','Robbery|Weather -S.E.','AllCrimes|Weather -E','AllCrimes|Weather -S.E.']
df = df[cols]
df.to_csv('Crime Prediction CSV MOCK - revised.csv',index=False)

##Prepare first 24 hrs of prediction data of tomorrow for the use of validation_Jiajun
#Update the 24hrs of prediction for tomorrow only after 18:00:00 and before 20:00:00
import datetime
currentTime = datetime.datetime.now()
#if(currentTime.hour >= 18 and currentTime.hour < 20):
onedayDelta = datetime.timedelta(days = 1)
dateTmr = str(currentTime.date() + onedayDelta)
output_cols = ['census_tra', 'dt', 'hournumber', 'ViolentCrime -E', 'Assault -E', 'Robbery -E']
df_output = df[output_cols]
df_output['date'] = [str(dt.date())for dt in df_output['dt']]  
df_output = df_output[df_output['date'] == dateTmr]
df_output['date'] = [str(dt.date())for dt in df_output['dt']]  
df_output.to_csv('prediction_daily_' + dateTmr + '.csv', index=False)

