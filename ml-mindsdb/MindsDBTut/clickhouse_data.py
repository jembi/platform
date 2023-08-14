from clickhouse_driver import Client
import mindsdb_sdk


def run():



    # print(table.query(expr='Given_Name'))
    #
    # print(dbs[0].get_table("data_1_4").db)

    # connect to ClickHouse - make a request
    client = Client(host='localhost', port=9000)
    query = 'SELECT * FROM table_1'
    result = client.execute(query)

    for row in result:
        # Process each row of the result
        print(row)

