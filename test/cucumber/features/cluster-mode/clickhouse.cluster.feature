Feature: Analytics Datastore Clickhouse?
    Does the Analytics Datastore Clickhouse package work as expected

  Scenario: Init Analytics Datastore Clickhouse
    Given I use parameters "package init -n=analytics-datastore-clickhouse --dev --env-file=.env.cluster"
    When I launch the platform with params
    Then The service "analytics-datastore-clickhouse-01" should be started with 1 replica
    And The service "analytics-datastore-clickhouse-01" should be connected to the networks
      | clickhouse_public | clickhouse_default | minio_public |
    And The service "analytics-datastore-clickhouse-02" should be started with 1 replica
    And The service "analytics-datastore-clickhouse-02" should be connected to the networks
      | clickhouse_public | clickhouse_default | minio_public |
    And The service "analytics-datastore-clickhouse-03" should be started with 1 replica
    And The service "analytics-datastore-clickhouse-03" should be connected to the networks
      | clickhouse_public | clickhouse_default | minio_public |
    And The service "analytics-datastore-clickhouse-04" should be started with 1 replica
    And The service "analytics-datastore-clickhouse-04" should be connected to the networks
      | clickhouse_public | clickhouse_default | minio_public |
    And The service "clickhouse-config-importer" should be removed
    And There should be 4 services

  Scenario: Destroy Analytics Datastore Clickhouse
    Given I use parameters "package destroy -n=analytics-datastore-clickhouse --dev --env-file=.env.cluster"
    When I launch the platform with params
    Then The service "analytics-datastore-clickhouse-01" should be removed
    And The service "analytics-datastore-clickhouse-02" should be removed
    And The service "analytics-datastore-clickhouse-03" should be removed
    And The service "analytics-datastore-clickhouse-04" should be removed
    And There should be 0 service
    And There should be 0 volume
    And There should be 0 config
    And There should not be network
      | clickhouse_public | minio_public |
