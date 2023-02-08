Feature: Monitoring package?
    Does the Monitoring package work as expected

    Scenario: Init Monitoring
        Given I use parameters "init monitoring --only --dev --env-file=.env.local"
        When I launch the platform with params
        Then The service "grafana" should be started with 1 replica
        And The service "prometheus" should be started with 1 replica
        And The service "cadvisor" should be started with 1 replica
        And The service "node-exporter" should be started with 1 replica
        And The service "cadvisor" should have healthy containers
        And The service "loki" should be started with 1 replica
        And The service "promtail" should be started with 1 replica
        And The service "minio-01" should be started with 1 replica
        And There should be 6 volumes

    Scenario: Destroy Monitoring package
        Given I use parameters "destroy monitoring --dev --env-file=.env.cluster"
        When I launch the platform with params
        Then The service "grafana" should be removed
        And The service "prometheus" should be removed
        And The service "cadvisor" should be removed
        And The service "node-exporter" should be removed
        And The service "loki" should be removed
        And The service "promtail" should be removed
        And The service "minio-01" should be removed
        And There should be 0 service
        And There should be 0 volume
        And There should be 0 config
