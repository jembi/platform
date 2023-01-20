Feature: Analytics Datastore Clickhouse?
    Does the Analytics Datastore Clickhouse package work as expected

    Scenario: Init Analytics Datastore Clickhouse
        Given I use parameters "init analytics-datastore-clickhouse --dev --env-file=.env.local"
        When I launch the platform with params
        Then The service "analytics-datastore-clickhouse" should be started with 1 replica
        And The service "clickhouse-config-importer" should be removed
        And There should be 1 service
        And There should be 1 volume

    Scenario: Destroy Analytics Datastore Clickhouse
        Given I use parameters "destroy analytics-datastore-clickhouse --dev --env-file=.env.local"
        When I launch the platform with params
        Then The service "analytics-datastore-clickhouse" should be removed
        And There should be 0 service
        And There should be 0 volume
        And There should be 0 config
