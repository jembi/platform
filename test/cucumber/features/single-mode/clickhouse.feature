Feature: Analytics Datastore Clickhouse?
    Does the Analytics Datastore Clickhouse package work as expected

    Scenario: Init Analytics Datastore Clickhouse
        Given I use parameters "init analytics-datastore-clickhouse --dev --env-file=.env.local"
        When I launch the platform with params
        Then The service "analytics-datastore-clickhouse" should be started with 1 replicas
        And The service "clickhouse-config-importer" should be removed
        And There should be 1 services
        And There should be 1 volumes

    Scenario: Destroy Analytics Datastore Clickhouse
        Given I use parameters "destroy analytics-datastore-clickhouse --dev --env-file=.env.local"
        When I launch the platform with params
        Then The service "analytics-datastore-clickhouse" should be removed
        And There should be 0 services
        And There should be 0 volumes
        And There should be 0 configs
