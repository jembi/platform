from dateutil.relativedelta import relativedelta
from pmdarima.arima import auto_arima
import pickle
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates


model_name = 'time_poly_model.pkl'
poly_model = pickle.load(open('venv/resources/polynomial_regression_model.sav', 'rb'))

p, d, q = 2, 2, 2
# p - how many previous values should be considered - Auto Regressive
# d - number of times the data has been differenced to achieve stationarity - Integrated
# q - how many previous error terms should be considered - Moving Average


def rally():
    data = pd.read_csv("venv/resources/time_series_poly.csv")[['yearmonth', 'count', 'class', 'poly_pred', 'res_noise']]
    data['yearmonth'] = pd.to_datetime(data['yearmonth'], format='%Y-%m-%d')
    train_data = data[['yearmonth', 'res_noise']].set_index('yearmonth')
    # data = data.set_index('yearmonth')
    # print(data)

    train_size = 0.85
    split_idx = round(len(train_data) * train_size)

    train = train_data.iloc[:split_idx]
    test = train_data.iloc[split_idx:]

    build_model(train)
    load_model(data, train, test)


def build_model(train):
    model = auto_arima(train,
                       start_p=p,
                       d=d,
                       start_q=q,
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
    with open(model_name, 'wb') as pkl:
        pickle.dump(model, pkl)

    return model


def load_model(data, train, test, model=None):
    if model is None:
        with open(model_name, 'rb') as pkl:
            model = pickle.load(pkl)
    else:
        model = build_model(train)

    print(model.summary())

    # the start value is dependent on the output value of 'd'
    predictions, conf_int = model.predict_in_sample(start=d, end=672, return_conf_int=True)
    # lower_bound = conf_int[:, 0]
    # upper_bound = conf_int[:, 1]

    data = data.set_index('yearmonth')
    pred = pd.DataFrame(predictions, columns=['pred_noise'])
    pred = pred.rename_axis(index='yearmonth')
    pred['lower'] = [num[0] for num in conf_int]
    pred['upper'] = [num[1] for num in conf_int]

    new_data = new_dataframe(data, pred)
    new_data.to_csv("venv/resources/results_poly_auto_arima.csv")
    plot_results(new_data)


def plot_results(new_data):
    plt.plot(new_data['yearmonth'][:637], new_data['count'][:637],
             label="Real Data")                                      # show real data
    plt.plot(new_data['yearmonth'][1:], new_data['pred_count'][1:],
             label="Prediction")                                     # show predictions
    plt.plot(new_data['yearmonth'], new_data['poly_pred'],
             label="Polynomial Regression line")                     # show polynomial regression
    # plt.fill_between(new_data['yearmonth'],
    #                  new_data['pred_upper'],
    #                  new_data['pred_lower'],
    #                  color='lightgray', alpha=0.7,
    #                  label='Confidence Interval')
    plt.ylabel("Count")
    plt.xlabel("Year-Month")
    plt.title('Time Series Quad Data')

    years_locator = mdates.YearLocator()
    years_formatter = mdates.DateFormatter('%Y')
    plt.gca().xaxis.set_major_locator(years_locator)
    plt.gca().xaxis.set_major_formatter(years_formatter)

    plt.xticks(rotation=45)

    plt.grid(axis='x')
    plt.legend()

    plt.show()


def new_dataframe(data, pred):
    date_range = pd.date_range(start=min(min(pred.index), min(data.index)), end=max(max(pred.index), max(data.index)),
                               freq='MS')
    nd = []
    for date in date_range:
        if date in data.index and date in pred.index:
            nd.append([date] + list(data.loc[date]) + list(pred.loc[date]))
        elif date in data.index and date not in pred.index:
            nd.append([date] + list(data.loc[date]) + [0, 0, 0])
        elif date not in data.index and date in pred.index:
            nd.append([date, pd.NA, pd.NA, pd.NA, pd.NA] + list(pred.loc[date]))
        else:
            print("Oh no!")
    new_data = pd.DataFrame(nd,
                            columns=['yearmonth', 'count', 'class', 'poly_pred', 'res_noise',
                                     'pred_noise', 'lower', 'upper'])
    new_data['poly_pred'] = new_data['yearmonth'].apply(date_to_poly)
    new_data['count'].fillna(0, inplace=True)
    new_data['pred_count'] = [sum(cols) for cols in zip(new_data['poly_pred'], new_data['pred_noise'])]
    new_data['pred_upper'] = [sum(cols) for cols in zip(new_data['poly_pred'], new_data['upper'])]
    new_data['pred_lower'] = [sum(cols) for cols in zip(new_data['poly_pred'], new_data['lower'])]
    return new_data


def date_to_poly(date):
    now = pd.Timestamp("1970-01-01")
    rd = relativedelta(date, now)
    months_elapsed = rd.years*12 + rd.months
    return poly_model.intercept_ + poly_model.coef_[1]*months_elapsed + poly_model.coef_[2]*months_elapsed**2
