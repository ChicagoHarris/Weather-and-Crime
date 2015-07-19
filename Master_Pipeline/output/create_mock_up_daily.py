for i in range(1, 30):
    onedayDelta = datetime.timedelta(days = 1)
    idayDelta = datetime.timedelta(days = i)
    dateWant = str(currentTime.date() - idayDelta + onedayDelta)
    dateTmr = str(currentTime.date() + onedayDelta)
    output_cols = ['census_tra', 'dt', 'hournumber', 'ViolentCrime -E', 'Assault -E', 'Robbery -E']
    df_output = df[output_cols]
    df_output['date'] = [str(dt.date())for dt in df_output['dt']]  
    df_output = df_output[df_output['date'] == dateTmr]
    df_output['dt'] = [dt - idayDelta for dt in df_output['dt']]
    df_output['date'] = [str(dt.date())for dt in df_output['dt']]  
    df_output.to_csv('prediction_daily_' + dateWant + '.csv', index=False)

