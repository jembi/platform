from pmdarima.arima import auto_arima
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates


def build_model_full():

    data = pd.read_csv("venv/resources/time_series_data.csv", header=None)
    data.columns = ["yearmonth", "count", "class"]
    data['yearmonth'] = pd.to_datetime(data['yearmonth'], format='%Y-%m-%d')
    data = data[['yearmonth', 'count']].set_index('yearmonth')

    # print(data)

    train_size = 0.85
    split_idx = round(len(data) * train_size)

    train = data.iloc[:split_idx]           # first 80% of data
    test = data.iloc[split_idx:]            # remaining 20% of data

    # plot(train, test)

    model = auto_arima(train, start_p=0, d=1, start_q=0,
                       max_p=7, max_d=5, max_q=7,
                       max_order=None,
                       start_P=0, D=1, start_Q=1,
                       max_P=7, max_D=5, max_Q=7,
                       m=12, seasonal=True)

    print(model.summary())
    # model.plot_diagnostics().savefig('plot_diagnostics.png')

    pred_df = pd.DataFrame(model.predict(len(test)), index=test.index)
    print(pred_df)

    plt.plot(train, label="Train")
    plt.plot(test, label="Test")
    plt.plot(pred_df, label="Prediction")

    plt.ylabel("Count")
    plt.xlabel("Year-Month")
    plt.title('Time Series Data')

    years_locator = mdates.YearLocator()
    years_formatter = mdates.DateFormatter('%Y')
    plt.gca().xaxis.set_major_locator(years_locator)
    plt.gca().xaxis.set_major_formatter(years_formatter)

    plt.xticks(rotation=45)

    plt.grid(axis='x')

    plt.show()
