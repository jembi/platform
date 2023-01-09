Feature: Analytics Datastore Clickhouse?
    Does the Analytics Datastore Clickhouse package work as expected

    Scenario: Init Analytics Datastore Clickhouse
        Given I use parameters "init analytics-datastore-clickhouse --dev --env-file=.env.cluster"
        When I launch the platform with params
        Then The service "analytics-datastore-clickhouse-01" should be started
        And The service "analytics-datastore-clickhouse-02" should be started
        And The service "analytics-datastore-clickhouse-03" should be started
        And The service "analytics-datastore-clickhouse-04" should be started
        And The service "clickhouse-config-importer" should be removed
        And There should be 4 services
        And There should be 4 volumes

    Scenario: Destroy Analytics Datastore Clickhouse
        Given I use parameters "destroy analytics-datastore-clickhouse --dev --env-file=.env.cluster"
        When I launch the platform with params
        Then The service "analytics-datastore-clickhouse-01" should be removed
        And The service "analytics-datastore-clickhouse-02" should be removed
        And The service "analytics-datastore-clickhouse-03" should be removed
        And The service "analytics-datastore-clickhouse-04" should be removed
        And There should be 0 services
        And There should be 0 volumes
        And There should be 0 configs
