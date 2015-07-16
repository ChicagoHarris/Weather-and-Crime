import pandas as pd
import datetime
import numpy as np
import time
#import pdb

df=pd.read_csv('ChicagoWeather_Update_Metar.csv')


df['dt']=[datetime.datetime.strptime(str(dt),'%Y-%m-%dT%H:%M:%S').strftime('%Y-%m-%dT%H:00:00') for dt in df['dt']]
df = df.groupby(['dt']).mean()
#print df.index
df['dt']=[dt.replace('T',' ') for dt in df.index]
df['dewpoint_celsius'] = (df['dewpoint_fahrenheit']-32)*5.0/9.0
df['drybulb_celsius'] = (df['drybulb_fahrenheit']-32)*5.0/9.0
df['relative_humidity']=100*(np.exp((17.625*df['dewpoint_celsius'])/(243.04+df['dewpoint_celsius']))/np.exp((17.625*df['drybulb_celsius'])/(243.04+df['drybulb_celsius'])))
df=df.drop(['wban_code','wetbulb_fahrenheit','dewpoint_fahrenheit','dewpoint_celsius','drybulb_celsius'],1)
df = df.reset_index(drop=True)

df_plenario = pd.read_csv('ChicagoWeather_Update_.csv')
df_plenario['dt']=[datetime.datetime.strptime(str(dt),'%Y-%m-%dT%H:%M:%S').strftime('%Y-%m-%dT%H:00:00') for dt in df_plenario['dt']]
df_plenario = df_plenario.groupby(['dt']).mean()
df_plenario['dt']=[dt.replace('T',' ') for dt in df_plenario.index]
df_plenario = df_plenario.drop(['wban_code'],1)
df_plenario = df_plenario[df.columns]
df_plenario = df_plenario.reset_index(drop=True)

df = df.append(df_plenario)
df = df.groupby(['dt'])['wind_speed','relative_humidity','hourly_precip','drybulb_fahrenheit'].mean()
df['dt']=pd.to_datetime(df.index)
df=df.reset_index(drop=True)
df['hournumber']=[dt.hour for dt in df['dt']]
df['year'] = [dt.year for dt in df['dt']]
#df['dt'] = [str(dt).replace('T',' ') for dt in df.index]


df_forecasts = pd.read_csv('forecasts.csv')
cols = df_forecasts.columns
df = df[cols].append(df_forecasts)

df = df.reset_index(drop=True)
df['dod1_drybulb_fahrenheit'] = 0
df['dod2_drybulb_fahrenheit'] = 0
df['dod3_drybulb_fahrenheit'] = 0
df['wow1_drybulb_fahrenheit'] = 0
df['wow2_drybulb_fahrenheit'] = 0
df['hour_count_since_precip'] = -1
df['precip_hour_cnt_in_last_1_week'] = 0
df['precip_hour_cnt_in_last_1_day'] = 0
df['precip_hour_cnt_in_last_3_day'] = 0

df['window']=[(datetime.datetime.strptime(str(dt),'%Y-%m-%d %H:00:00')-datetime.datetime.today()).days for dt in df['dt'].values]
relevant = len(df)-len(df[df['window']>=0])

for i in range(relevant,len(df)):
    df.ix[i,'dod1_drybulb_fahrenheit'] = df.ix[i,'drybulb_fahrenheit'] - df.ix[i-24,'drybulb_fahrenheit']
    df.ix[i,'dod2_drybulb_fahrenheit'] = df.ix[i,'drybulb_fahrenheit'] - df.ix[i-48,'drybulb_fahrenheit']
    df.ix[i,'dod3_drybulb_fahrenheit'] = df.ix[i,'drybulb_fahrenheit'] - df.ix[i-72,'drybulb_fahrenheit']
    df.ix[i,'wow1_drybulb_fahrenheit'] = df.ix[i,'drybulb_fahrenheit'] - df.ix[i-168,'drybulb_fahrenheit']
    df.ix[i,'wow2_drybulb_fahrenheit'] = df.ix[i,'drybulb_fahrenheit'] - df.ix[i-336,'drybulb_fahrenheit']
    for j in range(1,i):
    	if df.ix[i - j,'hourly_precip'] > .001:
    		df.ix[i,'hour_count_since_precip'] = j
    		break
    precip_1wk_cnt = 0
    precip_1d_cnt = 0
    precip_3d_cnt = 0
    for k in range(1,168):
    	if df.ix[i - k,'hourly_precip'] > .001:
    		if k <= 24:
    			precip_1d_cnt += 1
    			precip_1wk_cnt+=1
    			precip_3d_cnt+=1
    		elif k <= 72:
    			precip_1wk_cnt+=1
    			precip_3d_cnt+=1
    		else:
    			precip_1wk_cnt+=1
    df.ix[i,'precip_hour_cnt_in_last_1_week'] = precip_1wk_cnt
    df.ix[i,'precip_hour_cnt_in_last_1_day'] = precip_1d_cnt
    df.ix[i,'precip_hour_cnt_in_last_3_day'] = precip_3d_cnt


df = df[ (df['window']>=0) & (df['window']<=2)]
df = df.drop('window',1)

f = open('census_ids.txt')
census_ids = pd.DataFrame([ids.strip() for ids in f.readlines()])
census_ids.columns = ['census_tra']
census_ids['key'] = 1
df['key'] = 1
final_joined = pd.merge(df,census_ids,on='key')
final_joined = final_joined.drop(['key'],1)
#print final_joined['dt']
#final_joined['id'] = final_joined['census_tra'].astype(str) + final_joined['dt'].astype(str).str.replace('/','')


df = final_joined
cols = ['census_tra','year','hournumber','dt','shooting_count','robbery_count','assault_count','hourstart','wind_speed','drybulb_fahrenheit','hourly_precip','relative_humidity','fz','ra','ts','br','sn','hz','dz','pl','fg','sa','up','fu','sq','gs','dod1_drybulb_fahrenheit','dod2_drybulb_fahrenheit','dod3_drybulb_fahrenheit','wow1_drybulb_fahrenheit','wow2_drybulb_fahrenheit','precip_hour_cnt_in_last_1_day','precip_hour_cnt_in_last_3_day','precip_hour_cnt_in_last_1_week','hour_count_since_precip','day_of_week','month_of_year']

df['month_of_year']=pd.DatetimeIndex(df['dt']).month
df['day_of_week']=pd.DatetimeIndex(df['dt']).dayofweek
df['hourstart'] = df['hournumber']
df['shooting_count'] = 0
df['robbery_count'] = 0
df['assault_count'] = 0
df['fz'] = 0
df['ra'] = 0
df['ts'] = 0
df['br'] = 0
df['sn'] = 0
df['hz'] = 0
df['dz'] = 0
df['pl'] = 0
df['fg'] = 0
df['sa'] = 0
df['up'] = 0
df['fu'] = 0
df['sq'] = 0
df['gs'] = 0

df = df[cols]
#pdb.set_trace()
#df=df.tail(105240)
df.to_csv('lagged_forecasts.csv',index=False)

#df.to_csv('lagged_weather.csv',index=False)
