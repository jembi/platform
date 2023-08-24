import pandas as pd
import matplotlib.pyplot as plt


def show():

    df = pd.read_csv('venv/resources/time_series_data.csv')[:-1]
    res = pd.read_csv('venv/resources/time_data_results_mindsdb.csv')

    df['yearmonth'] = pd.to_datetime(df['yearmonth'])
    res['yearmonth'] = pd.to_datetime(res['yearmonth'])

    print(res)

    plt.plot(df['yearmonth'], df['count'], label="Training data")
    plt.plot(res['yearmonth'], res['count'], label="Predictions")
    plt.xlabel('Month-Year')
    plt.ylabel("HIV Incidence rate")
    plt.legend()
    plt.show()
