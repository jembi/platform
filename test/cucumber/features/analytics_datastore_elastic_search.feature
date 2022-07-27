Feature: Analytics Datastore ElasticSearch?
    Does the elastic search package work as expected

    Scenario: Init Analytics Datastore ElasticSearch
        Given I use parameters "init analytics-datastore-elastic-search --dev --env-file=.env.test"
        When I launch the platform with params
        Then The service "analytics-datastore-elastic-search" should be started
        And The service "analytics-datastore-elastic-search" should have healthy containers
        And The volume "es-data" should be created

    Scenario: Destroy Analytics Datastore ElasticSearch
        Given I use parameters "destroy analytics-datastore-elastic-search --dev --env-file=.env.test"
        When I launch the platform with params
        Then The service "analytics-datastore-elastic-search" should be removed
        And The service containers for "analytics-datastore-elastic-search" should be removed
        And The volume "es-data" should be removed
