Feature: Dashboard Visualiser Kibana?
    Does the elastic search package work as expected

    Scenario: Init Dashboard Visualiser Kibana
        Given I use parameters "init dashboard-visualiser-kibana --dev --env-file=.env.test"
        When I launch the platform with params
        Then The service "analytics-datastore-elastic-search" should be started
        Then The service "dashboard-visualiser-kibana" should be started
        And There should be 2 services
        And The service "analytics-datastore-elastic-search" should have healthy containers
        And The service "dashboard-visualiser-kibana" should have healthy containers
        And The volume "es-data" should be created
        And There should be 1 volume

    Scenario: Destroy Dashboard Visualiser Kibana
        Given I use parameters "destroy dashboard-visualiser-kibana --dev --env-file=.env.test"
        When I launch the platform with params
        Then The service "analytics-datastore-elastic-search" should be removed
        Then The service "dashboard-visualiser-kibana" should be removed
        And There should be 0 services
        And The service containers for "dashboard-visualiser-kibana" should be removed
        And The volume "es-data" should be removed
        And There should be 0 volumes
