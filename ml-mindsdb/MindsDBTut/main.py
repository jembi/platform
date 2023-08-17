from time import time

from another_arima_model import build_model_full
import arima_model
import arima_poc
import connect_clickhouse
import generate_quad_data
import polynomial_trend_poc
import poly_arima_poc
import process_fhir
import mindsdb_tut
import mindsdb_poc
import append_synthetic_data
import generate_time_series
import prophet_poc


def main():
    # append_synthetic_data.generate()      # generate HIV confirmation date and Viral Load from synthetic data
    # generate_time_series.time_series()    # collate HIV CONF into HIV incidence per month
    # generate_quad_data.build_data()       # generate inverse quadratic data trend - HIV incidence per month
    # process_fhir.execute()                # pulling data from FHIR resource
    # mindsdb_tut.orchestrate()             # old MindsDB implementation
    # mindsdb_poc.organise()                # interact with MindsDB container - import data, set up project, model, jobs
    # arima_poc.assemble()                  # build ARIMA model with pmdarima library - configure parameters
    # polynomial_trend_poc.unite()          # calculate polynomial regression line - return intercept and coefficients
                                            # generate residual noise between poly trend and real data
    # poly_arima_poc.rally()                # calculate ARIMA model on residual noise - combine polynomial and arima
    # prophet_poc.orchestrate()             # implement FB's timeseries forecasting model -> Prophet
    connect_clickhouse.orchestrate()      # connect to ClickHouse server and push predicted data to DB


if __name__ == '__main__':
    s = time()
    main()
    e = time()
    print("Runtime: {}".format(e-s))
