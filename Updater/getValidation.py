import pandas as pd
import numpy as np

# Directory pointing to the daily prediction files
dir_prediction = "../Master_Pipeline/output/"

# Directory pointing to the output file
dir_output = dir_prediction

df = pd.read_csv('WeatherandCrime_Data_Iter.csv')

cols = ['census_tra', 'hourstart', 'dt', 'shooting_count', 'robbery_count', 'assault_count']
df = df[cols]
#df['dt'] = pd.to_datetime(df['dt'])

predictionDataFrame = None

allDates = np.unique(df['dt'])
totalDate = len(allDates)

#We only select the last seven days as validation set

selectedDate = allDates[totalDate - 8: totalDate - 1]

df = df[df['dt'].isin(selectedDate)]


for date in selectedDate:
    df1 = pd.read_csv(dir_prediction + "prediction_daily_" + date + ".csv")
    predictionDataFrame = pd.concat([predictionDataFrame, df1])

predictionDataFrame['hourstart'] = predictionDataFrame['dt']
predictionDataFrame['hourstart'] = pd.to_datetime(predictionDataFrame['hourstart'])
df['hourstart'] = pd.to_datetime(df['hourstart'])

joinedCSV = pd.merge(df, predictionDataFrame, on = ['census_tra', 'hourstart'])
totalRows = len(joinedCSV)

joinedCSV['Assault Binary'] = joinedCSV['Assault -E'] >= 0.5
joinedCSV['assault_count'] = joinedCSV['assault_count'] > 0
joinedCSV['Assault Accurate Num'] = [joinedCSV.ix[i]['assault_count'] == joinedCSV.ix[i]['Assault Binary'] for i in range(totalRows)]

joinedCSV['Robbery Binary'] = joinedCSV['Robbery -E'] >= 0.5
joinedCSV['robbery_count'] = joinedCSV['robbery_count'] > 0
joinedCSV['Robbery Accurate Num'] = [joinedCSV.ix[i]['robbery_count'] == joinedCSV.ix[i]['Robbery Binary'] for i in range(totalRows)]

joinedCSV['ViolentCrime Binary'] = joinedCSV['ViolentCrime -E'] >= 0.5
joinedCSV['shooting_count'] = joinedCSV['shooting_count'] > 0
joinedCSV['ViolentCrime Accurate Num'] = [joinedCSV.ix[i]['shooting_count'] == joinedCSV.ix[i]['ViolentCrime Binary'] for i in range(totalRows)]

joinedCSV['totalCount'] = 1

g = joinedCSV.groupby("hournumber")

df2= g.sum().reset_index()

df2['Assault Accuracy Rate'] = df2['Assault Accurate Num'] / df2['totalCount']
df2['Assault Accuracy Rate'] = df2['Assault Accuracy Rate'].values.round(decimals=3)
df2['Robbery Accuracy Rate'] = df2['Robbery Accurate Num'] / df2['totalCount']
df2['Robbery Accuracy Rate'] = df2['Robbery Accuracy Rate'].values.round(decimals=3)
df2['ViolentCrime Accuracy Rate'] = df2['ViolentCrime Accurate Num'] / df2['totalCount']
df2['ViolentCrime Accuracy Rate'] = df2['ViolentCrime Accuracy Rate'].values.round(decimals=3)

outputCol = ['hournumber', 'Assault Accuracy Rate', 'Robbery Accuracy Rate', 'ViolentCrime Accuracy Rate']
df2 = df2[outputCol]

##This is the accuracy file we will post on the website(overwrite the old one)
df2.to_csv(dir_output + 'validation_accuracy.csv', index = False)

##This is the accuracy file we will post on the github(don't overwrite the old one)
import datetime
now = datetime.datetime.now()
currentDate = now.strftime(%Y-%m-%d)
df2.to_csv(dir_output + 'validation_accuracy' + currentDate + ".csv", index = False)








