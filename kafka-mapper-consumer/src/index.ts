import { Kafka, logLevel } from "kafkajs";
import Fhirpath from "fhirpath";
import fhirMappings from "../fhir-mapping.json"; 

interface Entry {
  resource: Resource;
}

interface Resource {
  resourceType: string;
  id: string;
}

interface ResourceMap {
  [key: string]: any;
}

interface TableMappingProperties{
  targetTable: string, 
  filter?: string,
  columnMappings: []
}
const kafkaHost = process.env.KAFKA_HOST || "localhost";
const kafkaPort = process.env.KAFKA_PORT || "9092";

const kafka = new Kafka({
  logLevel: logLevel.INFO,
  brokers: [`${kafkaHost}:${kafkaPort}`],
  clientId: "kafka-mapper-consumer",
});

const consumer = kafka.consumer({ groupId: "kafka-mapper-consumer" });
const producer = kafka.producer();

const run = async () => {
  let topics: string[] = []; 
  fhirMappings.map((resource => {
    topics.push(resource.resourceType.toLowerCase())
  }))

  await consumer.connect();
  await producer.connect();
  await consumer.subscribe({ topics, fromBeginning: true }); 

  await consumer.run({
    eachMessage: async ({topic, partition, message}) => {
      const prefix = `${topic}[${partition} | ${message.offset}] / ${message.timestamp}`;
      console.log(`- ${prefix} ${message.key}#${message.value}`);

      const resourceObject: Entry = JSON.parse(message.value?.toString() ?? "")
      const fhirMapping = fhirMappings.find((mapping) => mapping.resourceType.toLowerCase() === topic); 
      let tempObject: ResourceMap = {}         
      fhirMapping?.tableMappings.map((tableMapping)=>{ 
               
        tableMapping.columnMappings.map((column) => {
          tempObject[column.columnName] = Fhirpath.evaluate(resourceObject,`${column.fhirPath}`) 

        })
      })  
        
        //send to kafka or to clickhouse

    }
  });
};

run().catch((e: Error) => console.error(`[kafka-mapper-consumer] ${e.message}`, e));

const errorTypes = ["unhandledRejection", "uncaughtException"];
const signalTraps = ["SIGTERM", "SIGINT", "SIGUSR2"];

errorTypes.forEach((type) => {
  process.on(type, async (e: Error) => {
    try {
      console.log(`process.on ${type}`);
      console.error(e);
      await consumer.disconnect();
      await producer.disconnect();
      process.exit(0);
    } catch (_) {
      process.exit(1);
    }
  });
});

signalTraps.forEach((type) => {
  process.once(type, async () => {
    try {
      await consumer.disconnect();
      await producer.disconnect();
    } finally {
      process.kill(process.pid, type);
    }
  });
});
