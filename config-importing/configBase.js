'use strict'

var axios = require('axios')
var FormData = require('form-data')
var fs = require('fs')
const path = require('path')

const SERVICE_NAME = process.env.SERVICE_NAME
const API_PASSWORD = process.env.API_PASSWORD
const SERVICE_API_PORT = process.env.SERVICE_API_PORT
const API_PATH = process.env.API_PATH
const API_USERNAME = process.env.API_USERNAME
const INSECURE = process.env.INSECURE
const CALLER_ID = process.env.CALLER_ID

switch (CALLER_ID) {
  case 'jsr_config_importer':
    var data = new FormData()
    data.append('form', fs.createReadStream(path.resolve(__dirname, 'export.jsrexport')))
    break;

  case 'openhim_config_importer':
    const jsonData = JSON.parse(
      fs.readFileSync(path.resolve(__dirname, 'openhim-import.json'))
    )
    data = JSON.stringify(jsonData)
    break;

  default:
    break;
}

var protocol
if (INSECURE) {
  protocol = 'http'
} else {
  protocol = 'https'
}

var config = {
  method: 'post',
  url: `${protocol}://${SERVICE_NAME}:${SERVICE_API_PORT}${API_PATH}`,
  // url: `http://localhost:5488/api/import`,
  auth: {
    username: API_USERNAME,
    password: API_PASSWORD
  },
  // auth: {
  //   username: 'admin',
  //   password: 'dev_password_only'
  // },
  headers: {
    'Content-Type': 'application/json',
    ...data.getHeaders()
  },
  data: data,
}

axios(config)
  .then(function (response) {
    console.log(JSON.stringify(response.data))
  })
  .catch(function (error) {
    console.log(error)
  })
