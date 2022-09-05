Feature: Analytics Datastore ElasticSearch?
    Does the elastic search package work as expected

    Scenario: Init Analytics Datastore ElasticSearch
        Given I use parameters "init analytics-datastore-elastic-search --dev --env-file=.env.test"
        When I launch the platform with params
        Then The service "analytics-datastore-elastic-search" should be started
        And There should be 1 service
        And The service "analytics-datastore-elastic-search" should have healthy containers
        And The volume "es-data" should be created
        And There should be 1 volume

    Scenario: Destroy Analytics Datastore ElasticSearch
        Given I use parameters "destroy analytics-datastore-elastic-search --dev --env-file=.env.test"
        When I launch the platform with params
        Then The service "analytics-datastore-elastic-search" should be removed
        And There should be 0 services
        And The volume "es-data" should be removed
        And There should be 0 volumes
