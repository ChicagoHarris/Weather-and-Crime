import pandas as pd
import numpy as np

# Directory pointing to the daily prediction files
dir_prediction = ""

# Directory pointing to the output file
dir_output = ""

df = pd.read_csv('WeatherandCrime_Data_Iter.csv')

cols = ['census_tra', 'hourstart', 'dt', 'shooting_count', 'robbery_count', 'assault_count']
df = df[cols]
#df['dt'] = pd.to_datetime(df['dt'])

predictionDataFrame = None

allDates = np.unique(df['dt'])
totalDate = len(allDates)

#We only select the last seven days as validation set

selectedDate = allDates[totalDate - 8: totalDate - 1]

df = df[df['dt'].isin(selectedData)]


for date in selectedDate:
    df1 = pd.read_csv(dir_prediction + "_daily_" + date + ".csv")
    pd.concat([predictionDataFrame, df1])

predictionDataFrame['hourstart'] = predictionDataFrame['dt']
predictionDataFrame['hourstart'] = pd.to_datetime(predictionDataFrame['hourstart'])
df['hourstart'] = pd.to_datetime(df['hourstart'])

joinedCSV = pd.merge(df, predictionDataFrame, on = ['census_tra', 'hourstart'])


g = joinedCSV.groupby("hourstart")

g.sum().reset_index()





