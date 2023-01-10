Feature: Openhim and its dependent packages?
    Does Openhim and its dependent packages work as expected

    Scenario: Init Interoperability Layer Openhim
        Given I use parameters "init interoperability-layer-openhim --dev --env-file=.env.cluster"
        When I launch the platform with params
        Then The service "mongo-1" should be started with 1 replicas
        And The service "mongo-2" should be started with 1 replicas
        And The service "mongo-3" should be started with 1 replicas
        And The service "openhim-core" should be started with 3 replicas
        And The service "openhim-console" should be started with 3 replicas
        And The service "interoperability-layer-openhim-config-importer" should be removed
        And There should be 5 services

    Scenario: Destroy Openhim and its dependent packages
        Given I use parameters "destroy interoperability-layer-openhim mpi-mediator --only --dev --env-file=.env.cluster"
        When I launch the platform with params
        Then The service "mongo-1" should be removed
        And The service "mongo-2" should be removed
        And The service "mongo-3" should be removed
        And The service "openhim-core" should be removed
        And The service "openhim-console" should be removed
        And The service "mpi-mediator" should be removed
        And There should be 0 services
        And There should be 0 volumes
        And There should be 0 configs
