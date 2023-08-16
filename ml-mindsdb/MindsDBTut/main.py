from time import time

import logistic_arima_poc
from another_arima_model import build_model_full
import arima_model
import arima_poc
import connect_clickhouse
import generate_new_data
import logistic_arima_poc
import logistic_arima_poc
import poly_arima_poc
import process_fhir
import mindsdb_tut
import mindsdb_poc
import generate
import generate_time_series
import prophet_poc


def main():
    # arima_model.show_model()
    # arima_model.project()
    # generate_time_series.time_series()
    # generate.generate()
    # process_fhir.execute()               # pulling data from FHIR resource
    # mindsdb_tut.orchestrate()
    # mindsdb_poc.organise()
    # arima_poc.assemble()
    # logistic_arima_poc.unite()
    # poly_arima_poc.rally()
    # generate_new_data.build_data()
    connect_clickhouse.connect()
    # prophet_poc.orchestrate()


if __name__ == '__main__':
    s = time()
    main()
    e = time()
    print("Runtime: {}".format(e-s))
