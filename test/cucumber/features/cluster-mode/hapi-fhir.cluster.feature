Feature: Fhir Datastore HAPI-FHIR?
    Does the Fhir Datastore HAPI-FHIR package work as expected

    Scenario: Init Fhir Datastore HAPI-FHIR
        Given I use parameters "init fhir-datastore-hapi-fhir --dev --env-file=.env.cluster"
        When I launch the platform with params
        Then The service "postgres-1" should be started with 1 replicas
        And The service "postgres-2" should be started with 1 replicas
        And The service "postgres-3" should be started with 1 replicas
        And The service "hapi-fhir" should be started with 3 replicas
        And There should be 4 services
        And The service "hapi-fhir" should have healthy containers

    Scenario: Init Message Bus Helper Hapi Proxy
        Given I use parameters "init message-bus-helper-hapi-proxy --only --dev --env-file=.env.cluster"
        When I launch the platform with params
        Then The service "hapi-proxy" should be started with 3 replicas
        And There should be 5 services

    Scenario: Destroy Fhir Datastore HAPI-FHIR
        Given I use parameters "destroy fhir-datastore-hapi-fhir message-bus-helper-hapi-proxy --only --dev --env-file=.env.cluster"
        When I launch the platform with params
        Then The service "postgres-1" should be removed
        And The service "postgres-2" should be removed
        And The service "postgres-3" should be removed
        And The service "hapi-fhir" should be removed
        And The service "hapi-proxy" should be removed
        And There should be 0 services
        And There should be 0 volumes
        And There should be 0 configs
