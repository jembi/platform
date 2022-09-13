'use strict'

const http = require('http')

const KAFDROP_HOST = process.env.KAFDROP_HOST || 'kafdrop'
const KAFDROP_PORT = process.env.KAFDROP_PORT || '9013'
const KAFKA_TOPICS = process.env.KAFKA_TOPICS

const defaultPartitions = 3
const defaultReplication = 1

const createKafkaTopic = (topic, partitions, replication) => {
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
  req.write(`name=${topic}&partitionsNumber=${partitions}&replicationFactor=${replication}`)
  req.end()
}

console.log('Creating kafka topics......................');

(() => {
  if (KAFKA_TOPICS) {
   KAFKA_TOPICS.split(',').forEach(topicCfg => {
      const [topic, partitions, replication] = topicCfg.split(':')
      createKafkaTopic(topic, partitions || defaultPartitions, replication || defaultReplication)
    })
  } else {
    console.log('Topics not created: KAFKA_TOPICS variable invalid')
    process.exit(1)
  }
})();
