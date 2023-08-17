import numpy.random
import pandas as pd
from datetime import datetime
import matplotlib.pyplot as plt
import numpy as np


def build_data():
    x_axis = [num for num in range(637)]
    y_axis = [func(num) for num in x_axis]
    x_dates = [pd.to_datetime('1970-01-01') + pd.DateOffset(months=num) for num in x_axis]
    class_column = ["high" for _ in x_axis]
    df = pd.DataFrame(zip(x_dates, y_axis, class_column), columns=["yearmonth", "count", "class"])
    df.to_csv("venv/resources/time_series_quad.csv")
    print(sum(y_axis))
    plt.plot(x_axis, y_axis)
    plt.show()


def func(x):
    return int(np.random.normal(graph(x), 2, 1))


def graph(x):
    return (-0.058 / 840) * x**2 + 0.058 * x + 10
