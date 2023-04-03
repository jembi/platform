Feature: Hapi Fhir and its dependent packages?
    Does Hapi Fhir and its dependent packages package work as expected

  Scenario: Init Fhir Datastore HAPI-FHIR
    Given I use parameters "package init -n=fhir-datastore-hapi-fhir --dev --env-file=.env.local"
    When I launch the platform with params
    Then The service "postgres-1" should be started with 1 replica
    And The service "hapi-fhir" should be started with 1 replica
    And There should be 2 services
    And The service "hapi-fhir" should have healthy containers
    And There should be 1 volume
    And There should be network
      | hapi-fhir_public | hapi-fhir_private | hapi-fhir_postgres_public | pg_backup | mpi_public |

  Scenario: Init Message Bus Helper Hapi Proxy
    Given I use parameters "package init -n=message-bus-helper-hapi-proxy --only --dev --env-file=.env.local"
    When I launch the platform with params
    Then The service "hapi-proxy" should be started with 1 replica
    And There should be 3 services
    And There should be network
      | kafka_public | openhim_public |

  Scenario: Destroy Hapi Fhir and its dependent packages
    Given I use parameters "package destroy -n=fhir-datastore-hapi-fhir,message-bus-helper-hapi-proxy --only --dev --env-file=.env.local"
    When I launch the platform with params
    Then The service "postgres-1" should be removed
    And The service "hapi-fhir" should be removed
    And The service "hapi-proxy" should be removed
    And There should be 0 service
    And There should be 0 volume
    And There should be 0 config
    And There should not be network
      | hapi-fhir_public | hapi-fhir_private | hapi-fhir_postgres_public | pg_backup | mpi_public | kafka_public | openhim_public |
