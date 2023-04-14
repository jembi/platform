Feature: Fhir Datastore HAPI-FHIR?
    Does the Fhir Datastore HAPI-FHIR package work as expected

  Scenario: Init Fhir Datastore HAPI-FHIR
    Given I use parameters "package init -n=fhir-datastore-hapi-fhir --dev --env-file=.env.cluster"
    When I launch the platform with params
    Then The service "postgres-1" should be started with 1 replica
    And The service "postgres-1" should be connected to the networks
      | hapi-fhir_postgres_public | hapi-fhir_default | pg_backup |
    And The service "postgres-2" should be started with 1 replica
    And The service "postgres-2" should be connected to the networks
      | hapi-fhir_postgres_public | hapi-fhir_default | pg_backup |
    And The service "postgres-3" should be started with 1 replica
    And The service "postgres-3" should be connected to the networks
      | hapi-fhir_postgres_public | hapi-fhir_default | pg_backup |
    And The service "hapi-fhir" should be started with 3 replicas
    And The service "hapi-fhir" should be connected to the networks
      | mpi_public | hapi-fhir_public | hapi-fhir_default |
    And There should be 4 services
    And The service "hapi-fhir" should have healthy containers

  Scenario: Init Message Bus Helper Hapi Proxy
    Given I use parameters "package init -n=message-bus-helper-hapi-proxy --only --dev --env-file=.env.cluster"
    When I launch the platform with params
    Then The service "hapi-proxy" should be started with 3 replicas
    And There should be 5 services
    And The service "hapi-proxy" should be connected to the networks
      | hapi-fhir_public | kafka_public | openhim_public |

  Scenario: Destroy Fhir Datastore HAPI-FHIR
    Given I use parameters "package destroy -n=fhir-datastore-hapi-fhir,message-bus-helper-hapi-proxy --only --dev --env-file=.env.cluster"
    When I launch the platform with params
    Then The service "postgres-1" should be removed
    And The service "postgres-2" should be removed
    And The service "postgres-3" should be removed
    And The service "hapi-fhir" should be removed
    And The service "hapi-proxy" should be removed
    And There should be 0 service
    And There should be 0 volume
    And There should be 0 config
    And There should not be network
      | hapi-fhir_public | hapi-fhir_postgres_public | mpi_public | kafka_public | openhim_public |
