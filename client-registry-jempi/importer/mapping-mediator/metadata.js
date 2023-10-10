'use strict'

const axios = require('axios')
const fs = require('fs')
const path = require('path')

const MEDIATOR_HOSTNAME = process.env.MEDIATOR_HOST_NAME || 'openhim-mapping-mediator'
const MEDIATOR_API_PORT = process.env.MEDIATOR_API_PORT || 3003

// Function for sending importing the configuration
const sendRequest = async (data, method, endpointId) => {
  const url = endpointId
    ? `http://${MEDIATOR_HOSTNAME}:${MEDIATOR_API_PORT}/endpoints/${endpointId}`
    : `http://${MEDIATOR_HOSTNAME}:${MEDIATOR_API_PORT}/endpoints`

  const options = {
    url: url,
    method: method,
    headers: {
      'Content-Type': 'application/json'
    },
    data: JSON.stringify(data)
  }

  try {
    const response = await axios(options)

    console.log(
      `Successfully Imported OpenHIM Mediator Config.\n\nImport summary:${JSON.stringify(
        response.data
      )}`
    )
  } catch (error) {
    throw new Error(
      `Failed to import OpenHIM Mediator config: ${error.message}`
    )
  }
}

const getEndpoints = async (callback) => {
  const options = {
    url: `http://${MEDIATOR_HOSTNAME}:${MEDIATOR_API_PORT}/endpoints`,
    method: 'get',
    headers: {
      'Content-Type': 'application/json'
    }
  }

  try {
    const response = await axios(options)
    callback(null, response.data)
  } catch (error) {
    callback(
      new Error(
        `Failed to fetch OpenHIM Mediator Mapping endpoints: ${error.response.data}`
      )
    )
  }
}

const importMetaData = async () => {
  // get the endpoints list incase we need to do a update instead of a create
  // If the endpoint already exists, perform an update
  getEndpoints((_error, endpoints) => {
    const dirPath = path.resolve(__dirname)
    const files = fs.readdirSync(dirPath)
    files.reduce((_acc, curr) => {
      const jsonRegex = /(.*?(\bjson\b)[^$]*)/

      if (curr.match(jsonRegex)) {
        let method = 'post'
        let endpointId = null

        const jsonData = JSON.parse(
          fs.readFileSync(path.join(dirPath, curr), 'utf8')
        )
        const matchingEndpoint = endpoints.filter(
          (endpoint) => endpoint.endpoint.pattern === jsonData.endpoint.pattern
        )[0]

        if (matchingEndpoint) {
          endpointId = matchingEndpoint._id
          method = 'put'
        }

        sendRequest(jsonData, method, endpointId)
      }
    }, {})
  })
}

importMetaData()
