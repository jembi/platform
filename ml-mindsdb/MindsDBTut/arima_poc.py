from pmdarima.arima import auto_arima
import pickle
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates


def assemble():
    data = pd.read_csv("venv/resources/time_series_quad.csv")[['yearmonth', 'count', 'class']]
    data['yearmonth'] = pd.to_datetime(data['yearmonth'], format='%Y-%m-%d')
    data = data[['yearmonth', 'count']].set_index('yearmonth')
    print(data)

    train_size = 0.85
    split_idx = round(len(data) * train_size)

    train = data.iloc[:split_idx]  # first 80% of data
    test = data.iloc[split_idx:]  # remaining 20% of data

    build_model(train)
    load_model(data, train, test)


def build_model(train):
    model = auto_arima(train,
                       start_p=2,           # how many previous values should be considered - Auto Regressive
                       d=2,                 # number of times the data has been differenced to achieve stationarity - Integrated
                       start_q=2,           # how many previous error terms should be considered - Moving Average
                       max_p=13,
                       max_d=13,
                       max_q=13,
                       max_order=None,
                       stepwise=True,
                       # start_P=1,
                       # D=1,
                       # start_Q=1,
                       # max_P=5,
                       # max_D=5,
                       # max_Q=5,
                       # m=12,
                       seasonal=False)

    # print(model.summary())
    # model.plot_diagnostics().savefig('plot_diagnostics.png')
    with open('time_quad_model_085.pkl', 'wb') as pkl:
        pickle.dump(model, pkl)

    return model


def load_model(data, train, test, model=None):
    if model is None:
        with open('time_quad_model.pkl', 'rb') as pkl:
            model = pickle.load(pkl)
    else:
        model = build_model(train)

    print(model.summary())

    predictions, conf_int = model.predict_in_sample(start=10, end=672, return_conf_int=True)
    lower_bound = conf_int[:, 0]
    upper_bound = conf_int[:, 1]

    # Wanted to output the next 3 years to compare to MindsDB
    # pred = pd.DataFrame(model.predict(36))
    # pred.to_csv("compare.csv")

    pred_df = pd.DataFrame(predictions)
    pred_df.to_csv("venv/resources/results_auto_arima.csv")

    plt.plot(data, label="Test")
    plt.plot(pred_df, label="Prediction")
    plt.fill_between(predictions.index[len(predictions) - 120:], lower_bound[len(predictions) - 120:],
                     upper_bound[len(predictions) - 120:], color='lightgray', alpha=0.7,
                     label='Confidence Interval')

    plt.ylabel("Count")
    plt.xlabel("Year-Month")
    plt.title('Time Series Data')

    years_locator = mdates.YearLocator()
    years_formatter = mdates.DateFormatter('%Y')
    plt.gca().xaxis.set_major_locator(years_locator)
    plt.gca().xaxis.set_major_formatter(years_formatter)

    plt.xticks(rotation=45)

    plt.grid(axis='x')
    plt.legend()

    plt.show()
