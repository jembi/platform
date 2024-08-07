'use strict';

const fs = require('fs');
const axios = require('axios');
const FormData = require('form-data');
const path = require('path');

const SUPERSET_SERVICE_NAME =
  process.env.SUPERSET_SERVICE_NAME || 'dashboard-visualiser-superset';
const SUPERSET_API_PORT = process.env.SUPERSET_API_PORT || 8088;
const SUPERSET_API_PASSWORD = process.env.SUPERSET_API_PASSWORD || 'admin';
const SUPERSET_API_USERNAME = process.env.SUPERSET_API_USERNAME || 'admin';
const SUPERSET_LOGIN_PATH =
  process.env.SUPERSET_LOGIN_PATH || '/api/v1/security/login';
const SUPERSET_IMPORT_PATH =
  process.env.SUPERSET_IMPORT_PATH || '/api/v1/assets/import/';
const SUPERSET_DATABASE_PUT_PATH =
  process.env.SUPERSET_DATABASE_PUT_PATH || '/api/v1/database';
const CONFIG_FILE = process.env.CONFIG_FILE;
const SUPERSET_SSL = process.env.SUPERSET_SSL || 'false';

const protocol = SUPERSET_SSL == 'false' ? 'http' : 'https';

const getAccessToken = async () => {
  const data = JSON.stringify({
    password: SUPERSET_API_PASSWORD,
    username: SUPERSET_API_USERNAME,
    provider: 'db',
    refresh: true,
  });

  const config = {
    method: 'POST',
    url: `${protocol}://${SUPERSET_SERVICE_NAME}:${SUPERSET_API_PORT}${SUPERSET_LOGIN_PATH}`,
    headers: {
      'Content-Type': 'application/json',
    },
    data: data,
  };
  try {
    const res = await axios(config);

    console.log('\nAccess token was generated successfully');

    return res.data.access_token;
  } catch (error) {
    console.error('\nFailed to generate access token', error);
    process.exit(1);
  }
};

const importZipConfig = async (accessToken) => {
  const data = new FormData();

  if (CONFIG_FILE) {
    data.append(
      'bundle',
      fs.createReadStream(path.resolve(__dirname, CONFIG_FILE))
    );

    const config = {
      method: 'POST',
      url: `${protocol}://${SUPERSET_SERVICE_NAME}:${SUPERSET_API_PORT}${SUPERSET_IMPORT_PATH}`,
      headers: {
        'Content-Type': 'application/zip',
        Authorization: `Bearer ${accessToken}`,
        ...data.getHeaders(),
      },
      data: data,
    };

    const res = await axios(config);

    console.log('\n', res.data);
    console.log('\nConfig imported successfully. exit.');
  } else {
    throw new Error(
      '\nNo path was provided. Please provide the path of the config.'
    );
  }
}

const replaceClickhouseConnectionString = async (accessToken) => {
  const CLICKHOUSE_HOST = process.env.CLICKHOUSE_HOST || 'analytics-datastore-clickhouse';
  const CLICKHOUSE_PORT = process.env.CLICKHOUSE_PORT || '8123';
  const CLICKHOUSE_PASSWORD = process.env.CLICKHOUSE_PASSWORD || 'dev_password_only';

  const databaseConfig = {
    allow_ctas: false,
    allow_cvas: false,
    allow_dml: false,
    allow_file_upload: false,
    allow_run_async: false,
    cache_timeout: 0,
    configuration_method: "sqlalchemy_form",
    database_name: "Clickhouse connection",
    driver: "connect",
    engine: "clickhousedb",
    expose_in_sqllab: true,
    sqlalchemy_uri: `clickhousedb+connect://default:${CLICKHOUSE_PASSWORD}@${CLICKHOUSE_HOST}:${CLICKHOUSE_PORT}/default`,
    uuid: "868ecd6d-f099-46ab-a100-dd91173bc63f"
  };

  const config = {
    method: 'POST',
    url: `${protocol}://${SUPERSET_SERVICE_NAME}:${SUPERSET_API_PORT}${SUPERSET_DATABASE_PUT_PATH}`,
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${accessToken}`
    },
    data: databaseConfig,
  };

  const res = await axios(config);

  console.log('\n', res.data);
  console.log('\Database connection updated successfully. exit.');
}

(async () => {
  try {
    const accessToken = await getAccessToken();

    if (accessToken) {
      await importZipConfig(accessToken);
      await replaceClickhouseConnectionString(accessToken);
    } else {
      throw new Error('\nNo access token was generated.');
    }
  } catch (err) {
    console.error('\n', err);
    console.error('\nFailed ... exit.');
    process.exit(1);
  }
})();
