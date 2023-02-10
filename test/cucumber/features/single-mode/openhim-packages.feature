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

  Scenario: Init Client Registry JemMPI
    Given I use parameters "package init -n=client-registry-jempi --only --dev --env-file=.env.local"
    When I launch the platform with params
    Then The service "jempi-kafka-01" should be started with 1 replica
    And The service "jempi-kafka-02" should be started with 1 replica
    And The service "jempi-kafka-03" should be started with 1 replica
    And The service "jempi-ratel" should be started with 1 replica
    And The service "jempi-alpha-01" should be started with 1 replica
    And The service "jempi-alpha-02" should be started with 1 replica
    And The service "jempi-alpha-03" should be started with 1 replica
    And The service "jempi-async-receiver" should be started with 1 replica
    And The service "jempi-sync-receiver" should be started with 1 replica
    And The service "jempi-pre-processor" should be started with 1 replica
    And The service "jempi-controller" should be started with 1 replica
    And The service "jempi-em-calculator" should be started with 1 replica
    And The service "jempi-linker" should be started with 1 replica
    And The service "jempi-kafdrop" should be started with 1 replica
    And The service "jempi-zero-01" should be started with 1 replica
    And The service "jempi-api" should be started with 1 replica
    And There should be 20 services
    And There should be 9 volumes

  Scenario: Destroy Openhim and its dependent packages
    Given I use parameters "package destroy -n=interoperability-layer-openhim,client-registry-jempi,openhim-mapping-mediator --only --dev --env-file=.env.local"
    When I launch the platform with params
    Then The service "mongo-1" should be removed
    And The service "openhim-core" should be removed
    And The service "openhim-console" should be removed
    And The service "jempi-kafka-01" should be removed
    And The service "jempi-kafka-02" should be removed
    And The service "jempi-kafka-03" should be removed
    And The service "jempi-ratel" should be removed
    And The service "jempi-alpha-01" should be removed
    And The service "jempi-alpha-02" should be removed
    And The service "jempi-alpha-03" should be removed
    And The service "jempi-async-receiver" should be removed
    And The service "jempi-sync-receiver" should be removed
    And The service "jempi-pre-processor" should be removed
    And The service "jempi-controller" should be removed
    And The service "jempi-em-calculator" should be removed
    And The service "jempi-linker" should be removed
    And The service "jempi-kafdrop" should be removed
    And The service "jempi-zero-01" should be removed
    And The service "jempi-api" should be removed
    And The service "openhim-mapping-mediator" should be removed
    And There should be 0 service
    And There should be 0 volume
    And There should be 0 config
