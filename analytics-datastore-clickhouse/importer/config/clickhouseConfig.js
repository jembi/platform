'use strict';

const { ClickHouse } = require('clickhouse');
const queries = require('./clickhouseTables');

const CLICKHOUSE_HOST =
  process.env.CLICKHOUSE_HOST || 'analytics-datastore-clickhouse';
const CLICKHOUSE_PORT = parseInt(process.env.CLICKHOUSE_PORT || '8123');
const CLICKHOUSE_DEBUG = Boolean(process.env.CLICKHOUSE_DEBUG || false);

const clickhouse = new ClickHouse({
  url: CLICKHOUSE_HOST,
  port: CLICKHOUSE_PORT,
  debug: CLICKHOUSE_DEBUG,
  raw: true,
});

(async () => {
  for (const query of queries) {
    try {
      const r = await clickhouse.query(query).toPromise();

      if (r.includes('Exception')) throw new Error(r);
      else console.log(query, '\n', r);
    } catch (err) {
      console.error(err);
      process.exit(1);
    }
  }
})();
