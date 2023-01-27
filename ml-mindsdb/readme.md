`./purge-local.sh ; ./build-image.sh && ./platform-linux --env-file=.env.local --dev init ml-mindsdb`

Go to mindsdb UI: <http://localhost:47334/>

```sql
--- After you fill all the mandatory fields run the query with the top button or shift + enter. 
    
CREATE DATABASE clickhouse  --- display name for database. 
WITH ENGINE = 'clickhouse',   --- name of the mindsdb handler 
PARAMETERS = {
  "host": "analytics-datastore-clickhouse",                --- host name or IP address
  "port": 9000,                   --- port used to make TCP/IP connection
  "database": "default",            --- database name
  "user": "default",                --- database user
  "password": ""            --- database password
};

show databases;

--- load data set - https://clickhouse.com/docs/en/getting-started/example-datasets/uk-price-paid
select COUNT(*) from clickhouse.uk_price_paid;

select * from clickhouse.uk_price_paid
LIMIT 100;

CREATE MODEL mindsdb.house_sales3
FROM clickhouse
  (select * from uk_price_paid limit 100)
PREDICT price

select * from mindsdb.predictors

select price, price_explain
FROM mindsdb.house_sales3
WHERE town='PERRANPORTH'
AND type='terraced'

DESCRIBE MODEL mindsdb.house_sales3;
DESCRIBE MODEL mindsdb.house_sales3.features;
```
