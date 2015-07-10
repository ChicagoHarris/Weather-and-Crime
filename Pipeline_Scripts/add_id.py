#This file will finish any formatting for the website by adding unique ids and creating placeholder values for variables that are missing.

import pandas as pd
df = pd.read_csv('prediction_robbery.csv')
df_assault = pd.read_csv('prediction_assault.csv')
df_shooting = pd.read_csv('prediction_shooting.csv')

df['dt'] = pd.to_datetime(df['dt'])
df['id'] = df['census_tra'].astype(str)+[dt.strftime('%Y%m%d') for dt in df['dt']]+df['hournumber'].astype(str)
df['ViolentCrime -E'] = 0
df['ViolentCrime -S.E.'] = 0
df['Assault -E'] = 0
df['Assault -S.E.'] = 0
df['PropertyCrime -E'] = 0
df['PropertyCrime -S.E.'] = 0
df['Robbery -E'] = 0
df['Robbery -S.E.'] = 0
df['AllCrimes -E'] = 0
df['AllCrimes -S.E.'] = 0
df['ViolentCrime|Weather -E'] = df_shooting['V1'].values
df['ViolentCrime|Weather -S.E.'] = 0
df['Assault|Weather -E'] = df_assault['V1'].values
df['Assault|Weather -S.E.'] = 0
df['PropertyCrime|Weather -E'] = 0
df['PropertyCrime|Weather -S.E.'] = 0
df['Robbery|Weather -E'] = df['prediction']
df = df.drop(['prediction','predictionBinary'],1)
df['Robbery|Weather -S.E.'] = 0
df['AllCrimes|Weather -E'] = 0
df['AllCrimes|Weather -S.E.'] = 0
df['Robbery Delta'] = df['Robbery|Weather -E'] - df['Robbery -E']
df['Assault Delta'] = df['Assault|Weather -E'] - df['Assault -E']
df['ViolentCrime Delta'] = df['ViolentCrime|Weather -E'] - df['ViolentCrime -E']
df['PropertyCrime Delta'] = df['PropertyCrime|Weather -E'] - df['PropertyCrime -E']
df['AllCrimes Delta'] = df['AllCrimes|Weather -E'] - df['AllCrimes -E']



cols = ['id','census_tra','dt','hournumber','ViolentCrime -E','ViolentCrime -S.E.','Assault -E','Assault -S.E.','Robbery -E','Robbery -S.E.','PropertyCrime -E','PropertyCrime -S.E.','AllCrimes -E','AllCrimes -S.E.','ViolentCrime|Weather -E','ViolentCrime|Weather -S.E.','Assault|Weather -E','Assault|Weather -S.E.','Robbery|Weather -E','Robbery|Weather -S.E.','PropertyCrime|Weather -E','PropertyCrime|Weather -S.E.','AllCrimes|Weather -E','AllCrimes|Weather -S.E.','ViolentCrime Delta','Robbery Delta','PropertyCrime Delta','AllCrimes Delta']
df = df[cols]
df.to_csv('Crime Prediction CSV MOCK - revised.csv',index=False)
