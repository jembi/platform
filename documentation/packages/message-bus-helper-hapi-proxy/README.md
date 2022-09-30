---
description: A helper package for the Kafka message bus.
---

# Message Bus Helper Hapi Proxy

A helper for Kafka message bus service, It sends data to the HAPI FHIR datastore and then to the Kafka message bus based on the response from HAPI FHIR.&#x20;

More particularly:&#x20;

1. It receives messages from OpenHIM&#x20;
2. It sends the data to the HAPI FHIR server and waits for the response
3. It gets the response. According to the response status, it will send the message to the topic that corresponds to that status (`2xx, 4xx, 5xx, ...` )
4. It will send back the response from HAPI FHIR to OpenHIM as well
