'use strict'

const http = require('http')

const KAFDROP_HOST = process.env.KAFDROP_HOST || 'kafdrop'
const KAFDROP_PORT = process.env.KAFDROP_PORT || '9013'
const KAFKA_PATIENT_TOPIC = process.env.KAFKA_PATIENT_TOPICS || '2xx-patient'
const KAFKA_BUNDLE_TOPIC = process.env.KAFKA_BUNDLE_TOPIC || '2xx'

const createKafkaTopic = topic => {
  const options = {
    protocol: 'http:',
    hostname: KAFDROP_HOST,
    path: '/topic',
    port: KAFDROP_PORT,
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    }
  }

  const req = http.request(options, res => {
    if (res.statusCode != 200) {
      throw Error(`Failed to create topic - ${topic}`)
    }
    console.log(`Created topic - ${topic}`)
  })
  req.write(`name=${topic}&partitionsNumber=1&replicationFactor=1`)
  req.end()
}

console.log('Creating kafka topics......................');

(() => {
  const topics = [KAFKA_PATIENT_TOPIC, KAFKA_BUNDLE_TOPIC]

  topics.forEach(topic => createKafkaTopic(topic))
})();
