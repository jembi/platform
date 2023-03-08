Feature: Client Registry JeMPI?
  Does the Client Registry JeMPI package work as expected

  Scenario: Init Client Registry JeMPI
    Given I use parameters "package init -n=message-bus-kafka,interoperability-layer-openhim,client-registry-jempi --only --dev --env-file=.env.local"
    When I launch the platform with params
    Then The service "mongo-1" should be started with 1 replica
    And The service "openhim-core" should be started with 1 replica
    And The service "openhim-console" should be started with 1 replica
    And The service "kafka-01" should be started with 1 replica
    And The service "kafka-02" should be started with 1 replica
    And The service "kafka-03" should be started with 1 replica
    And The service "kafdrop" should be started with 1 replica
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
    And The service "jempi-zero-01" should be started with 1 replica
    And The service "jempi-api" should be started with 1 replica

  Scenario: Destroy Client Registry JeMPI
    Given I use parameters "package destroy -n=message-bus-kafka,interoperability-layer-openhim,client-registry-jempi --dev --env-file=.env.local"
    When I launch the platform with params
    Then The service "client-registry-jempi" should be removed
    And The service "kafka-01" should be removed
    And The service "kafka-02" should be removed
    And The service "kafka-03" should be removed
    And The service "kafdrop" should be removed
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
    And The service "jempi-zero-01" should be removed
    And The service "jempi-api" should be removed
    And The service "mongo-1" should be removed
    And The service "openhim-core" should be removed
    And The service "openhim-console" should be removed
    And There should be 0 service
    And There should be 0 volume
    And There should be 0 config
