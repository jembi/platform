Feature: Openhim and its dependent packages?
    Does Openhim and its dependent packages work as expected

  Scenario: Init Interoperability Layer Openhim
    Given I use parameters "package init -n=interoperability-layer-openhim --dev --env-file=.env.cluster"
    When I launch the platform with params
    Then The service "mongo-1" should be started with 1 replica
    And The service "mongo-1" should be connected to the networks
      | openhim_mongo_public | mongo_backup | openhim_default |
    And The service "mongo-2" should be started with 1 replica
    And The service "mongo-2" should be connected to the networks
      | openhim_mongo_public | mongo_backup | openhim_default |
    And The service "mongo-3" should be started with 1 replica
    And The service "mongo-3" should be connected to the networks
      | openhim_mongo_public | mongo_backup | openhim_default |
    And The service "openhim-core" should be started with 3 replicas
    And The service "openhim-core" should be connected to the networks
      | reverse-proxy_public | keycloak_public | openhim_public | openhim_default |
    And The service "openhim-console" should be started with 3 replicas
    And The service "openhim-console" should be connected to the networks
      | reverse-proxy_public | keycloak_public | openhim_public | openhim_default | 
    And The service "interoperability-layer-openhim-config-importer" should be removed
    And There should be 5 services

  Scenario: Destroy Openhim and its dependent packages
    Given I use parameters "package destroy -n=interoperability-layer-openhim --dev --env-file=.env.cluster"
    When I launch the platform with params
    Then The service "mongo-1" should be removed
    And The service "mongo-2" should be removed
    And The service "mongo-3" should be removed
    And The service "openhim-core" should be removed
    And The service "openhim-console" should be removed
    And There should be 0 service
    And There should be 0 volume
    And There should be 0 config
    And There should not be network
      | reverse-proxy_public | keycloak_public | openhim_public | openhim_mongo_public | mongo_backup |
