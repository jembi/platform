Feature: Client Registry JeMPI?
    Does the Client Registry JeMPI package work as expected

  Scenario: Init Client Registry JeMPI
    Given I use parameters "package init -n=client-registry-santempi --dev --env-file=.env.local"
    When I launch the platform with params
    Then The service "postgres-1" should be started with 1 replica
    Then The service "santedb-www" should be started with 1 replica
    And The service "santedb-mpi" should be started with 1 replica
    And The service "santedb-mpi" should be connected to the networks
      | reverse-proxy_public | mpi_public | santedb_public | santempi_default | postgres_public |
    And The service "santedb-www" should be connected to the networks
      | reverse-proxy_public | santempi_default |
    And There should be 3 services
    And There should be 2 volumes

  Scenario: Destroy Client Registry JeMPI
    Given I use parameters "package destroy -n=client-registry-santempi --dev --env-file=.env.local"
    When I launch the platform with params
    Then The service "postgres-1" should be removed
    And The service "santedb-www" should be removed
    And The service "santedb-mpi" should be removed
    And There should be 0 service
    And There should be 0 volume
    And There should be 0 config
    And There should not be network
      | reverse-proxy_public | mpi_public | santedb_public | postgres_public |
