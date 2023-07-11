Feature: Dashboard Visualiser DHIS12
    Does the DHIS2 package work as expected

  Scenario: Init DHIS2
    Given I use parameters "package init -n=dashboard-visualiser-dhis2 --dev --env-file=.env.cluster"
    When I launch the platform with params
    Then The service "dhis-postgres-1" should be started with 1 replica
    And The service "dhis-postgres-1" should be connected to the networks
      | dhis_postgres_public | pg_backup |
    Then The service "dhis-postgres-2" should be started with 1 replica
    And The service "dhis-postgres-2" should be connected to the networks
      | dhis_postgres_public | pg_backup |
    Then The service "dhis-postgres-3" should be started with 1 replica
    And The service "dhis-postgres-3" should be connected to the networks
      | dhis_postgres_public | pg_backup |
    And The service "dashboard-visualiser-dhis2" should be started with 1 replica
    And There should be 2 services
    And The service "dashboard-visualiser-dhis2" should have healthy containers
    And The service "dashboard-visualiser-dhis2" should be connected to the networks
      | dhis2-public | dhis_postgres_public |
    And The service "dhis-postgres-1" should be connected to the networks
      | dhis_postgres_public | pg_backup |
    And There should be 1 volume

  Scenario: Destroy DHIS2
    Given I use parameters "package destroy -n=dashboard-visualiser-dhis2 --only --dev --env-file=.env.cluster"
    When I launch the platform with params
    Then The service "dhis-postgres-1" should be removed
    And The service "dashboard-visualiser-dhis2" should be removed
    And There should be 0 service
    And There should be 0 volume
    And There should be 0 config
    And There should not be network
      | dhis2-public | dhis-postgres_public |
