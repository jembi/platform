Feature: Client Registry JeMPI?
  Does the Client Registry JeMPI package work as expected

  Scenario: Init Client Registry JeMPI
    Given I use parameters "package up -n=client-registry-jempi --dev --env-file=.env.cluster"
    When I launch the platform with params
    Then The service "mongo-1" should be started with 1 replica
    And The service "mongo-1" should be started with 1 replica
    And The service "mongo-1" should be started with 1 replica
    And The service "openhim-core" should be started with 3 replica
    And The service "openhim-console" should be started with 3 replica
    And The service "kafka-01" should be started with 1 replica
    And The service "kafka-02" should be started with 1 replica
    And The service "kafka-03" should be started with 1 replica
    And The service "kafdrop" should be started with 1 replica
    And The service "kafka-minion" should be started with 1 replica
    And The service "postgres-1" should be started with 1 replica
    And The service "postgres-2" should be started with 1 replica
    And The service "postgres-3" should be started with 1 replica
    And The service "identity-access-manager-keycloak" should be started with 1 replica
    And The service "jempi-ratel" should be started with 1 replica
    And The service "jempi-alpha-01" should be started with 1 replica
    And The service "jempi-alpha-02" should be started with 1 replica
    And The service "jempi-alpha-03" should be started with 1 replica
    And The service "jempi-zero-01" should be started with 1 replica
    And The service "jempi-zero-02" should be started with 1 replica
    And The service "jempi-zero-03" should be started with 1 replica
    And The service "jempi-async-receiver" should be started with 1 replica
    And The service "jempi-async-receiver" should be connected to the networks
      | kafka_public | jempi_default |
    And The service "jempi-etl" should be started with 1 replica
    And The service "jempi-etl" should be connected to the networks
      | kafka_public | jempi_default |
    And The service "jempi-controller" should be started with 1 replica
    And The service "jempi-controller" should be connected to the networks
      | kafka_public | jempi_default |
    # jempi-em-calculator is not ready for testing yet
    # And The service "jempi-em-calculator" should be started with 3 replica
    # And The service "jempi-em-calculator" should be connected to the networks
    #   | kafka_public | jempi_default |
    And The service "jempi-linker" should be started with 1 replica
    And The service "jempi-linker" should be connected to the networks
      | kafka_public | jempi_default |
    And The service "jempi-api" should be started with 3 replica
    And The service "jempi-api" should be connected to the networks
      | kafka_public | jempi_default |
    And The service "jempi-postgresql-01" should be started with 1 replica
    And The service "jempi-postgresql-02" should be started with 1 replica
    And The service "jempi-postgresql-03" should be started with 1 replica
    And The service "jempi-web" should be started with 3 replica
    And The service "jempi-web" should be connected to the networks
      | reverse-proxy_public | keycloak_public | jempi_default |

  Scenario: Destroy Client Registry JeMPI
    Given I use parameters "package destroy -n=client-registry-jempi --dev --env-file=.env.cluster"
    When I launch the platform with params
    Then The service "client-registry-jempi" should be removed
    And The service "kafka-01" should be removed
    And The service "kafka-02" should be removed
    And The service "kafka-03" should be removed
    And The service "kafdrop" should be removed
    And The service "kafka-minion" should be removed
    And The service "postgres-1" should be removed
    And The service "postgres-2" should be removed
    And The service "postgres-3" should be removed
    And The service "identity-access-manager-keycloak" should be removed
    And The service "jempi-ratel" should be removed
    And The service "jempi-alpha-01" should be removed
    And The service "jempi-alpha-02" should be removed
    And The service "jempi-alpha-03" should be removed
    And The service "jempi-async-receiver" should be removed
    And The service "jempi-etl" should be removed
    And The service "jempi-controller" should be removed
    And The service "jempi-em-calculator" should be removed
    And The service "jempi-linker" should be removed
    And The service "jempi-zero-01" should be removed
    And The service "jempi-zero-02" should be removed
    And The service "jempi-zero-03" should be removed
    And The service "jempi-api" should be removed
    And The service "jempi-web" should be removed
    And The service "jempi-postgresql-01" should be removed
    And The service "jempi-postgresql-02" should be removed
    And The service "jempi-postgresql-03" should be removed
    And The service "mongo-1" should be removed
    And The service "mongo-2" should be removed
    And The service "mongo-3" should be removed
    And The service "openhim-core" should be removed
    And The service "openhim-console" should be removed
    And There should be 0 service
    And There should be 0 volume
    And There should be 0 config
    And There should not be network
      | keycloak_public | reverse-proxy_public | kafka_public |
