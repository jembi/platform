import pandas as pd
from matplotlib import pyplot as plt
# from prophet.plot import plot_plotly, plot_components_plotly
from prophet import Prophet


# file_name = 'time_series_quad.csv'
file_name = 'time_series_data.csv'


def orchestrate():
    data = import_data()
    split = int(len(data) * 0.90)
    train = data.iloc[:split]
    test = data.iloc[split:]
    # build_model(train)
    plot_model(build_model(train), data)


def import_data():
    df = pd.read_csv('venv/resources/{}'.format(file_name))
    df.reset_index(drop=True, inplace=True)
    df['yearmonth'] = pd.to_datetime(df['yearmonth'])
    df = df[['yearmonth', 'count']]
    df.columns = ['ds', 'y']
    return df


def build_model(train):
    model = Prophet()
    model.fit(train)

    pred = model.make_future_dataframe(periods=308, freq='MS')
    forecast = model.predict(pred)
    forecast.to_csv('venv/resources/prophet_results.csv')
    return forecast


def plot_model(forecast, data):
    plt.plot(data['ds'], data['y'], label='Prophet predictions')
    plt.plot(forecast['ds'], forecast['yhat'], label='Historical data')
    plt.plot(forecast['ds'], forecast['trend'], label='Prophet trend')
    plt.fill_between(forecast['ds'], forecast['trend_lower'], forecast['trend_upper'], label='Trend confidence', alpha=0.3, color='grey')
    plt.legend()
    plt.ylabel("Count")
    plt.xlabel("Time")
    plt.title("Time series predictions of HIV incidence rates using FB Prophet")
    plt.show()
