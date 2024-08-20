Feature: OpenFn?
    Does the OpenFn package work as expected

  Scenario: Init OpenFn
    Given I use parameters "package init -n=openfn --env-file=.env.local"
    When I launch the platform with params
    Then The service "openfn" should be started with 1 replica
    And There should be 3 service
    And The service "postgres-1" should be started with 1 replica
    And The service "worker" should be started with 1 replica
    And The service "openfn" should be connected to the networks
      | postgres_public | kafka_public |

  Scenario: Destroy OpenFn
    Given I use parameters "package destroy -n=openfn --env-file=.env.local"
    When I launch the platform with params
    Then The service "openfn" should be removed
    And The service "postgres-1" should be removed
    And The service "worker" should be removed
    And There should be 0 service
    And There should be 0 volume
    And There should be 0 config
    And There should not be network
      | postgres_public | kafka_public |
