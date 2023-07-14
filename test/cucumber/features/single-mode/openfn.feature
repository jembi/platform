Feature: Openfn?
    Does the Openfn package work as expected

  Scenario: Init Openfn
    Given I use parameters "package init -n=openfn --dev --env-file=.env.local"
    When I launch the platform with params
    Then The service "openfn-postgres-1" should be started with 1 replica
    And The service "openfn" should be started with 1 replica
    And There should be 2 services
    And The service "openfn" should have healthy containers
    And The service "openfn" should be connected to the networks
      | openhim_mapping_mediator_public | openfn_public | dhis_public |
    And The service "openfn-postgres-1" should be connected to the networks
      | openfn_postgres_public | pg_backup |
    And There should be 2 volume

  Scenario: Destroy Openfn
    Given I use parameters "package destroy -n=openfn --only --dev --env-file=.env.local"
    When I launch the platform with params
    Then The service "openfn-postgres-1" should be removed
    And The service "openfn" should be removed
    And There should be 0 service
    And There should be 0 volume
    And There should be 0 config
    And There should not be network
      | openfn_public | openfn_postgres_public | openhim_mapping_mediator_public | dhis_public |
