from clickhouse_connect import get_client
import pandas as pd


host = 'localhost'
port = 8123
username = 'default'
password = ''
database_name = 'clickhouse_db'
output_table_name = 'incidence_predictions'


def orchestrate():
    clickhouse = connect_client()
    # drop_table(clickhouse)
    # create_table(clickhouse)
    # add_row(pd.Timestamp('1970-05-01'), 15, 'real', clickhouse)     # example
    # upload_processed_data(clickhouse)
    # upload_predicted_data(clickhouse)
    show_table_contents(clickhouse)


def show_table_contents(clickhouse):
    # sql_query = "SELECT yearmonth, count FROM {}.{} WHERE category = 'real';".format(database_name, output_table_name)
    sql_query = "SELECT * FROM {}.{} WHERE category = 'pred' AND yearmonth > '2023-01-01';"\
        .format(database_name, output_table_name)
    data = fix_clickhouse_output(clickhouse.command(sql_query))
    for i in range(0, len(data), 3):
        print(data[i], data[i+1], data[i+2])


def upload_predicted_data(clickhouse):
    data = pd.read_csv('venv/resources/prophet_results_quad.csv')
    data['ds'] = pd.to_datetime(data['ds'])
    for ind, row in data.iterrows():
        add_row(row['ds'], row['yhat'], 'pred', clickhouse)


def upload_processed_data(clickhouse):
    data = pd.read_csv('venv/resources/time_series_quad.csv')
    data['yearmonth'] = pd.to_datetime(data['yearmonth'])
    for ind, row in data.iterrows():
        add_row(row['yearmonth'], float(row['count']), 'real', clickhouse)


def fix_clickhouse_output(data):
    # output for clickhouse command only separates on commas, not on newlines
    output = []
    for item in data:
        output.extend(item.split('\n'))
    return output


def add_row(date, count, category, clickhouse):
    clickhouse.insert(table=output_table_name,
                      database=database_name,
                      data=[(date, count, category)],
                      column_names=['yearmonth', 'count', 'category']
                      )


def drop_table(clickhouse):
    try:
        clickhouse.command('DROP TABLE {0}.{1};'.format(database_name, output_table_name))
    except:
        print("Generic error - cannot drop table: {}".format(output_table_name))


def create_table(clickhouse):
    clickhouse.command('CREATE TABLE IF NOT EXISTS {0}.{1} (yearmonth Date, count Float64, category String) '
                       'ENGINE = MergeTree() PRIMARY KEY (yearmonth);'.format(database_name, output_table_name))


def process_fhir():
    print("Pseudo code to pull FHIR resources from ClickHouse")
    print("Extract HIV confirmation dates")
    print("Collate to HIV incidence per month")


def connect_client():
    return get_client(host=host, port=port, username=username, password=password, database=database_name)
