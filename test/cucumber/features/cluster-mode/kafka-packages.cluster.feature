Feature: Kafka and its dependent packages?
    Does Kafka and its dependent packages work as expected

    Scenario: Init Message Bus Kafka
        Given I use parameters "init message-bus-kafka --dev --env-file=.env.cluster"
        When I launch the platform with params
        Then The service "zookeeper-1" should be started with 1 replicas
        And The service "zookeeper-2" should be started with 1 replicas
        And The service "zookeeper-3" should be started with 1 replicas
        And The service "kafka" should be started with 3 replicas
        And The service "kafdrop" should be started with 1 replicas
        And The service "kafka-minion" should be started with 1 replicas
        And The service "message-bus-kafka-config-importer" should be removed
        And There should be 6 services

    Scenario: Init Monitoring
        Given I use parameters "init monitoring --only --dev --env-file=.env.cluster"
        When I launch the platform with params
        Then The service "grafana" should be started with 1 replicas
        And The service "prometheus" should be started with 1 replicas
        And The service "prometheus-kafka-adapter" should be started with 1 replicas
        And The service "prometheus_backup" should be started with 1 replicas
        And The service "cadvisor" should be started with 3 replicas
        And The service "node-exporter" should be started with 3 replicas
        And The service "cadvisor" should have healthy containers

    Scenario: Destroy Kafka and its dependent packages
        Given I use parameters "destroy monitoring --dev --env-file=.env.cluster"
        When I launch the platform with params
        Then The service "zookeeper-1" should be removed
        And The service "zookeeper-2" should be removed
        And The service "zookeeper-3" should be removed
        And The service "kafka" should be removed
        And The service "kafdrop" should be removed
        And The service "kafka-minion" should be removed
        And The service "grafana" should be removed
        And The service "prometheus" should be removed
        And The service "prometheus-kafka-adapter" should be removed
        And The service "prometheus_backup" should be removed
        And The service "cadvisor" should be removed
        And The service "node-exporter" should be removed
        And There should be 0 services
        And There should be 0 volumes
        And There should be 0 configs
