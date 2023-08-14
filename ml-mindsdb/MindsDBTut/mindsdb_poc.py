from time import sleep

import matplotlib.pyplot as plt
import mindsdb_sdk
import pandas as pd


model_name = 'poc_hiv_model_ori'
database_name = 'clickhouse_db'
table_name = 'time_data'
project_name = 'demo_poc'
job_name = 'get_a_job_poc'


def organise():
    server = mindsdb_sdk.connect('http://127.0.0.1:47334')
    data = server.get_database(database_name).get_table(table_name)
    # connect_db(server)                # doesn't work yet, do via Browser UI
    # build_project(server)
    # remove_model(server)
    build_poc(server, data)
    # query_poc(server, data)
    plot_model(server, data, query_poc(server, data))


def connect_db(server):
    server.create_database(
        engine="clickhouse",
        name=database_name,
        connection_args={
            "user": "user",
            "password": "",
            "host": "mindsdb_clickhouse_1",
            "port": "8123",
            "database": "clickhouse_db"
        }
    )


def build_project(server):
    try:
        server.create_project(project_name)
    except RuntimeError:
        print("Project \'{}\' already exists".format(project_name))


def remove_model(server):
    try:
        server.get_project(project_name).drop_model(model_name)
        print("Model \'{}\' removed successfully".format(model_name))
    except AttributeError:
        print("Model \'{}\' does not exist".format(model_name))
    except RuntimeError:
        print("Model \'{}\' does not exist".format(model_name))


def build_poc(server, data):
    proj = server.get_project(project_name)

    model = proj.create_model(
        name=model_name,
        predict='count',
        engine='statsforecast',
        query=data,
        timeseries_options={
            'group': 'class',
            'order': 'yearmonth',
            'horizon': 24
        }
    )
    print("Create model \'{}\' executed".format(model_name))
    return model


def build_job(server):
    proj = server.get_project(project_name)

    query = 'FINETUNE {0}.{1}\n' \
            'FROM clickhouse_db (SELECT * FROM {2}.{3});\n'.format(project_name, model_name, database_name, table_name)

    try:
        remove_job(server)
        proj.create_job(
            name=job_name,
            query_str=query,
            repeat_str='15 minutes'
        )
        print("Job \'{}\' created".format(job_name))
    except AttributeError:
        print(AttributeError.name)


def remove_job(server):
    try:
        server.get_project(project_name).drop_job(job_name)
        print("Job \'{}\' dropped".format(job_name))
    except AttributeError:
        print("Job \'{}\' does not exist".format(job_name))


def query_poc(server, data):
    proj = server.get_project(project_name)
    model = proj.get_model(model_name)

    while model.get_status() != "complete":
        print("Training model")
        sleep(1)
    print("Model training complete")
    pred_df = model.predict(data)
    print(pred_df)

    return pred_df


def plot_model(server, data, results):
    time_data = pd.DataFrame(data.fetch())
    results['yearmonth'] = pd.to_datetime(results['yearmonth'])
    time_data['yearmonth'] = pd.to_datetime(time_data['yearmonth'])

    time_data.set_index('yearmonth', inplace=True)
    results.set_index('yearmonth', inplace=True)

    time_data = time_data.sort_values('yearmonth')
    results = results.sort_values('yearmonth')

    plt.plot(time_data["count"], label="Training data")
    # plt.plot(results["count_min"], label="Count_Min")
    # plt.plot(results["count_max"], label="Count_Max")
    plt.plot(results["count"], label="Prediction")

    plt.ylabel("Count")
    plt.xlabel("Year-Month")
    plt.title('Time Series Data')
    plt.legend()
    plt.savefig("results.png")
    plt.show()
