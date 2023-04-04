Feature: MPI mediator?
    Does the MPI mediator package work as expected

  Scenario: Init MPI mediator
    Given I use parameters "package init -n=message-bus-kafka,interoperability-layer-openhim,mpi-mediator --only --dev --env-file=.env.local"
    When I launch the platform with params
    Then The service "mpi-mediator" should be started with 1 replica
    And The service "mpi-mediator" should be connected to the networks
      | mpi_public | openhim_public | kafka_public | mpi_default |

  Scenario: Destroy MPI mediator
    Given I use parameters "package destroy -n=message-bus-kafka,interoperability-layer-openhim,mpi-mediator --dev --env-file=.env.local"
    When I launch the platform with params
    Then The service "mpi-mediator" should be removed
    And There should be 0 service
    And There should be 0 volume
    And There should be 0 config
    And There should not be network
      | openhim_public | kafka_public | mpi_public |
