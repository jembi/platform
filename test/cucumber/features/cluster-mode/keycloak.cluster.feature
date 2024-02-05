Feature: Identity Access Manager Keycloak?
    Does the Identity Access Manager Keycloak package work as expected

  Scenario: Init Identity Access Manager Keycloak
    Given I use parameters "package init -n=identity-access-manager-keycloak --dev --env-file=.env.cluster"
    When I launch the platform with params
    Then The service "postgres-1" should be started with 1 replica
    And The service "postgres-1" should be connected to the networks
      | pg_backup | postgres_default | postgres_public |
    And The service "postgres-2" should be started with 1 replica
    And The service "postgres-2" should be connected to the networks
      | pg_backup | postgres_default | postgres_public |
    And The service "postgres-3" should be started with 1 replica
    And The service "postgres-3" should be connected to the networks
      | pg_backup | postgres_default | postgres_public |
    And The service "identity-access-manager-keycloak" should be started with 1 replicas
    And The service "identity-access-manager-keycloak" should be connected to the networks
      | reverse-proxy_public | keycloak_public | keycloak_default | postgres_public |
    And There should be 4 services
    And The service "identity-access-manager-keycloak" should have healthy containers

  Scenario: Destroy Identity Access Manager Keycloak
    Given I use parameters "package destroy -n=identity-access-manager-keycloak --dev --env-file=.env.cluster"
    When I launch the platform with params
    Then The service "postgres-1" should be removed
    And The service "postgres-2" should be removed
    And The service "postgres-3" should be removed
    And The service "identity-access-manager-keycloak" should be removed
    And There should be 0 service
    And There should be 0 volume
    And There should be 0 config
    And There should not be network
      | reverse-proxy_public | keycloak_public | pg_backup | postgres_public| postgres_default |
