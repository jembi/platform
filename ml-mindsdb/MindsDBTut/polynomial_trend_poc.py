import numpy as np
import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import PolynomialFeatures, StandardScaler
import matplotlib.pyplot as plt
from dateutil.relativedelta import relativedelta
import pickle


def unite():
    # data = pd.read_csv("venv/resources/time_series_data.csv")[['yearmonth', 'count', 'class']]
    data = pd.read_csv("venv/resources/time_series_quad.csv")[['yearmonth', 'count', 'class']]
    data['yearmonth'] = pd.to_datetime(data['yearmonth'], format='%Y-%m-%d')
    data = adjust_date_column(data)
    model = build_regression(data)
    data = normalised_noise(data, model)


def normalised_noise(data, model):
    poly = PolynomialFeatures(2)
    noise = model.predict(poly.fit_transform(pd.DataFrame(data['months'])))
    data['poly_pred'] = noise
    data['res_noise'] = data['count'] - data['poly_pred']
    data.to_csv("venv/resources/time_series_poly.csv")
    return data


def build_regression(data):

    # print(data)

    x_train, x_test, y_train, y_test = train_test_split(data['months'], data['count'], test_size=0.23)
    x_train_df, x_test_df = pd.DataFrame(x_train), pd.DataFrame(x_test)

    poly = PolynomialFeatures(2)
    x_train_poly, x_test_poly = poly.fit_transform(x_train_df), poly.fit_transform(x_test_df)

    lin = LinearRegression()
    lin.fit(x_train_poly, y_train)

    print(lin.intercept_)
    print(lin.coef_)

    x_axis = [num for num in range(637)]
    y_axis = [lin.intercept_ + lin.coef_[1]*num + lin.coef_[2]*num**2 for num in x_axis]

    pred = lin.predict(x_test_poly)

    print(lin.score(x_test_poly, pd.DataFrame(y_test)))

    # plt.scatter(x_test, pred, label='Prediction')
    # plt.scatter(x_test, y_test, label="Actual")
    # plt.plot(x_axis, y_axis, label="Formula", color='red')
    # plt.legend()
    # plt.show()

    pickle.dump(lin, open('venv/resources/polynomial_regression_model.sav', 'wb'))

    return lin


def adjust_date_column(data):
    start_date = pd.Timestamp("1970-01-01")
    months_since = []
    for ind, row in data.iterrows():
        rd = relativedelta(row['yearmonth'], start_date)
        months_since.append(rd.years*12 + rd.months)
    data['months'] = months_since
    return data
