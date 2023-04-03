Feature: Identity Access Manager Keycloak?
    Does the Identity Access Manager Keycloak package work as expected

  Scenario: Init Identity Access Manager Keycloak
    Given I use parameters "package init -n=identity-access-manager-keycloak --dev --env-file=.env.local"
    When I launch the platform with params
    Then The service "keycloak-postgres-1" should be started with 1 replica
    And The service "identity-access-manager-keycloak" should be started with 1 replica
    And There should be 2 services
    And The service "identity-access-manager-keycloak" should have healthy containers
    And There should be 1 volume
    And There should be network
      | keycloak_public | keycloak_private | keycloak_backup |

  Scenario: Destroy Identity Access Manager Keycloak
    Given I use parameters "package destroy -n=identity-access-manager-keycloak --dev --env-file=.env.local"
    When I launch the platform with params
    Then The service "keycloak-postgres-1" should be removed
    And The service "identity-access-manager-keycloak" should be removed
    And The service "hapi-proxy" should be removed
    And There should be 0 service
    And There should be 0 volume
    And There should be 0 config
    And There should be network
      | keycloak_public | keycloak_private | keycloak_backup |
