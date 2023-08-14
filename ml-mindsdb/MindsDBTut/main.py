import pandas as pd
from time import time

import logistic_arima_poc
from another_arima_model import build_model_full
from arima_model import project, show_model
from arima_poc import assemble
from generate_new_data import build_data
from graph_results import graph
from logistic_arima_poc import unite
import logistic_arima_poc
from poly_arima_poc import rally
from process import execute
from mindsdb_tut import orchestrate
from mindsdb_poc import organise
from generate import generate
from generate_time_series import time_series
import matplotlib.pyplot as plt


def main():
    # show_model()
    # graph()
    # project()
    # time_series()
    # generate()
    # execute()
    # orchestrate()
    # organise()
    # assemble()
    # unite()
    rally()
    # build_data()


if __name__ == '__main__':
    s = time()
    main()
    e = time()
    print("Runtime: {}".format(e-s))
