Feature: Kafka and its dependent packages?
    Does Kafka and its dependent packages work as expected

    Scenario: Init Message Bus Kafka
        Given I use parameters "init message-bus-kafka --dev --env-file=.env.cluster"
        When I launch the platform with params
        Then The service "zookeeper-1" should be started with 1 replica
        And The service "zookeeper-2" should be started with 1 replica
        And The service "zookeeper-3" should be started with 1 replica
        And The service "kafka" should be started with 3 replicas
        And The service "kafdrop" should be started with 1 replica
        And The service "kafka-minion" should be started with 1 replica
        And The service "message-bus-kafka-config-importer" should be removed
        And There should be 6 services

    Scenario: Destroy Kafka and its dependent packages
        Given I use parameters "destroy message-bus-kafka --dev --env-file=.env.cluster"
        When I launch the platform with params
        Then The service "zookeeper-1" should be removed
        And The service "zookeeper-2" should be removed
        And The service "zookeeper-3" should be removed
        And The service "kafka" should be removed
        And The service "kafdrop" should be removed
        And The service "kafka-minion" should be removed
        And There should be 0 service
        And There should be 0 volume
        And There should be 0 config
