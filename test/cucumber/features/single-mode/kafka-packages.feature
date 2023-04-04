Feature: Kafka and its dependent packages?
  Does Kafka and its dependent packages work as expected

  Scenario: Init Message Bus Kafka
    Given I use parameters "package init -n=message-bus-kafka --dev --env-file=.env.local"
    When I launch the platform with params
    And The service "kafka-01" should be started with 1 replica
    And The service "kafdrop" should be started with 1 replica
    And The service "kafka-minion" should be started with 1 replica
    And The service "message-bus-kafka-config-importer" should be removed
    And The service "kafka-01" should be connected to the networks
      | kafka_public | kafka_default |
    And The service "kafdrop" should be connected to the networks
      | kafka_public | kafka_default |
    And The service "kafka-minion" should be connected to the networks
      | prometheus_public | kafka_default |
    And There should be 3 services
    And There should be 1 volumes

  Scenario: Init Kafka Mapper Consumer
    Given I use parameters "package init -n=kafka-mapper-consumer --only --dev --env-file=.env.local"
    When I launch the platform with params
    Then The service "kafka-mapper-consumer" should be started with 1 replica
    And The service "kafka-mapper-consumer" should be connected to the networks
      | clickhouse_public | kafka_public |

  Scenario: Init Message Bus Kafka
    Given I use parameters "package init -n=kafka-unbundler-consumer --only --dev --env-file=.env.local"
    When I launch the platform with params
    Then The service "kafka-unbundler-consumer" should be started with 1 replica
    And The service "kafka-unbundler-consumer" should be connected to the networks
      | kafka_public |

  Scenario: Destroy Kafka and its dependent packages
    Given I use parameters "package destroy -n=kafka-mapper-consumer,kafka-unbundler-consumer --dev --env-file=.env.local"
    When I launch the platform with params
    And The service "kafka-01" should be removed
    And The service "kafdrop" should be removed
    And The service "kafka-minion" should be removed
    And The service "kafka-mapper-consumer" should be removed
    And The service "kafka-unbundler-consumer" should be removed
    And There should be 0 service
    And There should be 0 volume
    And There should be 0 config
    And There should not be network
      | kafka_public  | clickhouse_public | prometheus_public |
