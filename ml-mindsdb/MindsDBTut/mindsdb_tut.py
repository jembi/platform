from time import sleep

import matplotlib.pyplot as plt

import mindsdb_sdk
import pandas as pd
from mindsdb_sql.parser.dialects import mindsdb


def orchestrate():
    server = mindsdb_sdk.connect('http://127.0.0.1:47334')
    time_data = server.get_database("clickhouse_db").get_table("time_data")       # original data
    # time_data = server.get_database("clickhouse_db").get_table("time_quad")         # quadratic data

    # remove_project(server)
    build_project(server)
    build_model(server, time_data)
    # retrieve_model(server, time_data)
    # build_job(server)
    # view_job(server)
    plot_model(retrieve_model(server, time_data), time_data)


def remove_project(server):
    proj = server.get_project('proj')
    proj.drop_model('hiv_model')
    server.drop_project('proj')


def build_project(server):
    server.create_project('proj')


def build_model(server, time_data):
    print(time_data.limit(5).fetch())
    project = server.get_project('proj')

    try:
        project.drop_model('hiv_model')
    except RuntimeError:
        print("Table 'hiv_model' do not exists")

    project.create_model(
        name='hiv_model',
        predict='count',
        engine='lightwood',
        query=time_data,
        timeseries_options={
            'group': 'class',
            'order': 'yearmonth',
            'window': 12,
            'horizon': 36
        }
    )


# kinda unnecessary with the JOBs function
def retrain_model(server, time_data):
    project = server.get_project('proj')
    model = project.get_model('hiv_model')
    model.retrain()


def retrieve_model(server, time_data):
    time_data = server.get_database("clickhouse_db").get_table("time_data")
    project = server.get_project('proj')

    model = project.get_model('hiv_model')

    while model.get_status() != "complete":
        print("Training model")
        sleep(1)
    pred_df = model.predict(time_data)

    return pred_df


def build_job(server):
    proj = server.get_project('proj')
    query = 'SELECT model.yearmonth AS yearmonth, model.count as count \nFROM mindsdb.proj.hiv_model as model \nJOIN ' \
            'clickhouse_db.time_data AS td \nWHERE td.yearmonth > LATEST \nAND td.class = \'high\'; '
    try:
        # proj.drop_job('get_a_job')
        proj.create_job(
            name='get_a_job',
            query_str=query,
            repeat_str='3 min'
        )
    except RuntimeError:
        print("Job already exists")


def view_job(server):
    proj = server.get_project('proj')
    job = proj.get_job('get_a_job')
    print(job.data)


def plot_model(results, ori):
    time_data = pd.DataFrame(ori.fetch())
    results['yearmonth'] = pd.to_datetime(results['yearmonth'])
    time_data['yearmonth'] = pd.to_datetime(time_data['yearmonth'])

    time_data.set_index('yearmonth', inplace=True)
    results.set_index('yearmonth', inplace=True)

    time_data = time_data.sort_values('yearmonth')
    results = results.sort_values('yearmonth')

    plt.plot(time_data["count"], label="Training data")
    plt.plot(results["count_min"], label="Count_Min")
    plt.plot(results["count_max"], label="Count_Max")
    plt.plot(results["count"], label="Prediction")

    plt.ylabel("Count")
    plt.xlabel("Year-Month")
    plt.title('Time Series Data')
    plt.legend()
    plt.show()
