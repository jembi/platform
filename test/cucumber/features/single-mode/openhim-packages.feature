Feature: Openhim and its dependent packages?
  Does Openhim and its dependent packages work as expected

  Scenario: Init Interoperability Layer Openhim
    Given I use parameters "package init -n=interoperability-layer-openhim --dev --env-file=.env.local"
    When I launch the platform with params
    Then The service "mongo-1" should be started with 1 replica
    And The service "openhim-core" should be started with 1 replica
    And The service "openhim-console" should be started with 1 replica
    And The service "await-helper" should be removed
    And The service "interoperability-layer-openhim-config-importer" should be removed
    And There should be 3 services
    And There should be 2 volumes

  Scenario: Init Openhim Mapping Mediator
    Given I use parameters "package init -n=openhim-mapping-mediator --only --dev --env-file=.env.local"
    When I launch the platform with params
    Then The service "openhim-mapping-mediator" should be started with 1 replica
    And There should be 4 services

  Scenario: Destroy Openhim and its dependent packages
    Given I use parameters "package destroy -n=interoperability-layer-openhim,client-registry-jempi,openhim-mapping-mediator --only --dev --env-file=.env.local"
    When I launch the platform with params
    Then The service "mongo-1" should be removed
    And The service "openhim-core" should be removed
    And The service "openhim-console" should be removed
    And The service "openhim-mapping-mediator" should be removed
    And There should be 0 service
    And There should be 0 volume
    And There should be 0 config
