---
description: >-
  Kafka is a stream processing platform which groups like-messages together,
  such that the number of sequential writes to disk can be increased, thus
  effectively increasing database speeds.
---

# Message Bus - Kafka

## Components

The message-bus-kafka package consists of a few components, those being Kafka, Kafdrop, and Kminion.

{% hint style="warning" %}
The services consuming from and producing to kafka might crash if Kafka is unreachable, so this is something to bear in mind when making changes to or restarting the kafka service.
{% endhint %}

### Kafka

The core stream-processing element of the message-bus-kafka package.

### Kafdrop

Kafdrop is a web user-interface for viewing Kafka topics and browsing consumer-groups.

### Kminion

A prometheus exporter for Kafka.
