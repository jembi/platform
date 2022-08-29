'use strict';

const { ClickHouse } = require('clickhouse');
const queries = require('./clickhouseTables');

const CLICKHOUSE_HOST =
  process.env.CLICKHOUSE_HOST || 'analytics-datastore-clickhouse';
const CLICKHOUSE_PORT = parseInt(process.env.CLICKHOUSE_PORT || '8123');

const clickhouse = new ClickHouse({
  url: CLICKHOUSE_HOST,
  port: CLICKHOUSE_PORT,
  debug: true,
});

(async () => {
  for (const query of queries) {
    const r = await clickhouse.query(query).toPromise();

    console.log(query, r);
  }
})();
