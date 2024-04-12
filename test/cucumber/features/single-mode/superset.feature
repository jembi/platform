Feature: Dashboard Visualiser Superset?
    Does the Dashboard Visualiser Superset package work as expected

  Scenario: Init Dashboard Visualiser Superset
    Given I use parameters "package init -n=dashboard-visualiser-superset --only --dev --env-file=.env.local"
    When I launch the platform with params
    Then The service "dashboard-visualiser-superset" should be started with 1 replica
    And The service "postgres-metastore" should be started with 1 replica
    And The service "superset-config-importer" should be removed
    And The service "ddashboard-visualiser-superset" should have healthy containers
    And The service "dashboard-visualiser-superset" should be connected to the networks
      | reverse-proxy_public | clickhouse_public | keycloak_public | superset_default |
    And There should be 2 service
    And There should be 3 volumes

  Scenario: Destroy Dashboard Visualiser Superset
    Given I use parameters "package destroy -n=dashboard-visualiser-superset --only --dev --env-file=.env.local"
    When I launch the platform with params
    Then The service "dashboard-visualiser-superset" should be removed
    And There should be 0 service
    And There should be 0 volume
    And There should be 0 config
    And There should not be network
      | reverse-proxy_public | clickhouse_public | keycloak_public | superset_default |
