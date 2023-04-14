Feature: Kafka and its dependent packages?
  Does Kafka and its dependent packages work as expected

  Scenario: Init Message Bus Kafka
    Given I use parameters "package init -n=message-bus-kafka --dev --env-file=.env.cluster"
    When I launch the platform with params
    Then The service "kafka-01" should be started with 1 replica
    And The service "kafka-01" should be connected to the networks
      | kafka_public | kafka_default |
    And The service "kafka-02" should be started with 1 replica
    And The service "kafka-02" should be connected to the networks
      | kafka_public | kafka_default |
    And The service "kafka-03" should be started with 1 replica
    And The service "kafka-03" should be connected to the networks
      | kafka_public | kafka_default |
    And The service "kafdrop" should be started with 1 replica
    And The service "kafdrop" should be connected to the networks
      | kafka_public | kafka_default |
    And The service "kafka-minion" should be started with 1 replica
    And The service "kafka-minion" should be connected to the networks
      | prometheus_public | kafka_default |
    And The service "message-bus-kafka-config-importer" should be removed
    And There should be 5 services

  Scenario: Destroy Kafka and its dependent packages
    Given I use parameters "package destroy -n=message-bus-kafka --dev --env-file=.env.cluster"
    When I launch the platform with params
    Then The service "kafka-01" should be removed
    And The service "kafka-02" should be removed
    And The service "kafka-03" should be removed
    And The service "kafka" should be removed
    And The service "kafdrop" should be removed
    And The service "kafka-minion" should be removed
    And There should be 0 service
    And There should be 0 volume
    And There should be 0 config
    And There should not be network
      | kafka_public  | clickhouse_public | prometheus_public |
