import pandas as pd

df_weather = pd.read_csv('Weather_Forecasts.csv')
df_accuracy = pd.read_csv('./output/validation_accuracy.csv')
df_weather = pd.merge(df_weather, df_accuracy, on = ['hournumber'])
df_weather = df_weather.sort(['dt'], ascending= [1])
df_weather[['wind_speed','relative_humidity','hourly_precip','drybulb_fahrenheit','Assault_Accuracy_Rate','Robbery_Accuracy_Rate','ViolentCrime_Accuracy_Rate','hournumber','year','dt','prediction_timestamp']].to_csv('Weather_Forecasts.csv', index=False)
