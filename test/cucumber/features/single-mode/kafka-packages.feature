Feature: Kafka and its dependent packages?
    Does Kafka and its dependent packages work as expected

    Scenario: Init Message Bus Kafka
        Given I use parameters "init message-bus-kafka --dev --env-file=.env.local"
        When I launch the platform with params
        Then The service "zookeeper-1" should be started with 1 replica
        And The service "kafka" should be started with 1 replica
        And The service "kafdrop" should be started with 1 replica
        And The service "kafka-minion" should be started with 1 replica
        And The service "message-bus-kafka-config-importer" should be removed
        And There should be 4 services
        And There should be 2 volumes

    Scenario: Init Kafka Mapper Consumer
        Given I use parameters "init kafka-mapper-consumer --only --dev --env-file=.env.local"
        When I launch the platform with params
        Then The service "kafka-mapper-consumer" should be started with 1 replica

    Scenario: Init Message Bus Kafka
        Given I use parameters "init kafka-unbundler-consumer --only --dev --env-file=.env.local"
        When I launch the platform with params
        Then The service "kafka-unbundler-consumer" should be started with 1 replica

    Scenario: Init Monitoring
        Given I use parameters "init monitoring --only --dev --env-file=.env.local"
        When I launch the platform with params
        Then The service "grafana" should be started with 1 replica
        And The service "prometheus" should be started with 1 replica
        And The service "prometheus-kafka-adapter" should be started with 1 replica
        And The service "cadvisor" should be started with 1 replica
        And The service "node-exporter" should be started with 1 replica
        And The service "cadvisor" should have healthy containers
        And There should be 4 volumes

    Scenario: Destroy Kafka and its dependent packages
        Given I use parameters "destroy kafka-mapper-consumer kafka-unbundler-consumer monitoring --dev --env-file=.env.local"
        When I launch the platform with params
        Then The service "zookeeper-1" should be removed
        And The service "kafka" should be removed
        And The service "kafdrop" should be removed
        And The service "kafka-minion" should be removed
        And The service "kafka-mapper-consumer" should be removed
        And The service "kafka-unbundler-consumer" should be removed
        And The service "grafana" should be removed
        And The service "prometheus" should be removed
        And The service "prometheus-kafka-adapter" should be removed
        And The service "cadvisor" should be removed
        And The service "node-exporter" should be removed
        And There should be 0 service
        And There should be 0 volume
        And There should be 0 config
