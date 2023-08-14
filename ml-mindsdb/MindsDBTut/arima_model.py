from pmdarima.arima import auto_arima
import pickle
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates


def project():
    data = pd.read_csv("venv/resources/time_series_data.csv", header=None)
    data.columns = ["yearmonth", "count", "class"]
    data['yearmonth'] = pd.to_datetime(data['yearmonth'], format='%Y-%m-%d')
    data = data[['yearmonth', 'count']].set_index('yearmonth')

    # print(data)

    train_size = 0.85
    split_idx = round(len(data) * train_size)

    train = data.iloc[:split_idx]  # first 80% of data
    test = data.iloc[split_idx:]  # remaining 20% of data

    # model = build_model(data)
    load_model(data, train, test)


def build_model(train):
    model = auto_arima(train, start_p=0, d=1, start_q=0,
                       max_p=5, max_d=5, max_q=5,
                       max_order=None,
                       start_P=0, D=1, start_Q=1,
                       max_P=5, max_D=5, max_Q=5,
                       m=10, seasonal=True)

    print(model.summary())
    # model.plot_diagnostics().savefig('plot_diagnostics.png')
    with open('arima_100.pkl', 'wb') as pkl:
        pickle.dump(model, pkl)

    return model


def load_model(data, train, test, model=None):
    if model is None:
        with open('arima_100.pkl', 'rb') as pkl:
            model = pickle.load(pkl)

    predictions, conf_int = model.predict_in_sample(start=1, end=700, return_conf_int=True)
    lower_bound = conf_int[:, 0]
    upper_bound = conf_int[:, 1]

    # Wanted to output the next 3 years to compare to MindsDB
    # pred = pd.DataFrame(model.predict(36))
    # pred.to_csv("compare.csv")

    pred_df = pd.DataFrame(predictions)
    pred_df.to_csv("venv/resources/results_auto_arima.csv")

    # plt.plot(train, label="Train")
    # plt.plot(test, label="Test")

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

    plt.show()

    # model


def show_model():
    with open('arima_100.pkl', 'rb') as pkl:
        model = pickle.load(pkl)

    print(model.summary)
