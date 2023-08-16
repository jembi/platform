from clickhouse_connect import get_client


def connect():
    client = get_client(host='localhost',
                        port=8123,
                        username='default',
                        password='',
                        database='clickhouse_db')

    command = client.command('SHOW DATABASES;')
    print(command)
