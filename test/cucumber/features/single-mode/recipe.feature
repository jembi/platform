Feature: CDR-DW recipe?
    Does the recipe work as expected  

  Scenario: Init the CDR recipe
    Given I use parameters "package init -p cdr-dw --dev --env-file=cdr-dw.env"
    When I launch the platform with params
    Then The service "mongo-1" should be started with 1 replica
    And The service "openhim-core" should be started with 1 replica
    And The service "openhim-console" should be started with 1 replica
    And The service "postgres-1" should be started with 1 replica
    And The service "hapi-fhir" should be started with 1 replica
    And The service "kafka-01" should be started with 1 replica
    And The service "kafdrop" should be started with 1 replica
    And The service "kafka-minion" should be started with 1 replica
    And The service "identity-access-manager-keycloak" should be started with 1 replica
    And The service "jempi-ratel" should be started with 1 replica
    And The service "jempi-alpha-01" should be started with 1 replica
    And The service "jempi-zero-01" should be started with 1 replica
    And The service "jempi-async-receiver" should be started with 1 replica
    And The service "kafka-unbundler-consumer" should be started with 1 replica
    And The service "kafka-mapper-consumer" should be started with 1 replica
    And The service "mpi-mediator" should be started with 1 replica
    And The service "openhim-mapping-mediator" should be started with 1 replica
    And The service "grafana" should be started with 1 replica
    And The service "prometheus" should be started with 1 replica
    And The service "cadvisor" should be started with 1 replica
    And The service "node-exporter" should be started with 1 replica
    And The service "cadvisor" should have healthy containers
    And The service "loki" should be started with 1 replica
    And The service "promtail" should be started with 1 replica
    And The service "minio-01" should be started with 1 replica
    And The service "dashboard-visualiser-superset" should be started with 1 replica
    And The service "analytics-datastore-clickhouse" should be started with 1 replica
    And The service "openfn" should be started with 1 replica

  Scenario: Send Fhir bundle and store the clinical data in the Fhir datastore, the patient info in the CR
    Given I have configured the cdr
    When I send a fhir patient bundle
    Then the clinical data should be stored in hapi fhir
    And the patient data in the Jempi client registry
    And the data should be stored in clickhouse

  Scenario: Fetch International Patient summary (IPS)
    When I then send a fhir patient summary request
    Then I should get a successful summary response

  Scenario: Fetch everything for a patient (all the clinical data)
    When I then send a request for all the patient's clinical data
    Then I should get a successful everything response

  Scenario: Bring down the servers
    Given I use parameters "package down -p cdr-dw --env-file=cdr-dw.env"
    When I launch the platform with params
    Then a request to fetch data from the cdr should fail

  Scenario: Bring up the servers and test
    Given I use parameters "package up -p cdr-dw --dev --env-file=cdr-dw.env"
    When I launch the platform with params
    Then The service "mongo-1" should be started with 1 replica
    And The service "openhim-core" should be started with 1 replica
    And The service "openhim-console" should be started with 1 replica
    And The service "postgres-1" should be started with 1 replica
    And The service "hapi-fhir" should be started with 1 replica
    When I then send a request for all the patient's clinical data
    Then I should get a successful everything response
    And the data should be stored in clickhouse

  Scenario: Destroy the services
    Given I use parameters "package remove -p cdr-dw --env-file=cdr-dw.env"
    When I launch the platform with params
    Then There should be 0 service
    And There should be 0 volume
